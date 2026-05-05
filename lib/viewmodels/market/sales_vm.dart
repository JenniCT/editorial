import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/global/dialog.dart'; 
import '../../models/sale_m.dart';


class SalesViewModel {
  final CollectionReference _salesCollection = FirebaseFirestore.instance.collection('sales');
  final CollectionReference _booksCollection = FirebaseFirestore.instance.collection('books');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===================================================================
  // IMPORTAR DESDE EXCEL
  // ===================================================================
  Future<void> importSalesFromExcel(List<Map<String, dynamic>> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Sesión no activa");

    debugPrint("Iniciando importación de ${data.length} filas...");

    final booksSnapshot = await _booksCollection.get();
    final allBooks = booksSnapshot.docs;

    for (var row in data) {
      String tituloExcel = (row['Título'] ?? row['titulo'] ?? row['TITULO'] ?? "")
          .toString()
          .trim();

      if (tituloExcel.isEmpty ||
          tituloExcel.toLowerCase() == "título" ||
          tituloExcel.toLowerCase() == "titulo") {
        debugPrint("Fila de encabezado o vacía detectada ('$tituloExcel'). Saltando...");
        continue;
      }

      int cantidad = int.tryParse((row['Cantidad'] ?? row['cantidad'] ?? "0").toString()) ?? 0;
      double total = double.tryParse((row['Total'] ?? row['total'] ?? "0").toString()) ?? 0.0;
      String lugar = (row['Lugar'] ?? row['lugar'] ?? "FIL UNACH").toString().trim();
      double precio = cantidad > 0 ? total / cantidad : 0.0;

      debugPrint("Procesando: '$tituloExcel' | Cantidad: $cantidad | Total: $total");

      if (cantidad <= 0) {
        debugPrint("Cantidad inválida para '$tituloExcel'. Saltando...");
        continue;
      }

      final bookDoc = allBooks.cast<QueryDocumentSnapshot?>().firstWhere(
        (doc) {
          final dbData = doc?.data() as Map<String, dynamic>;
          final dbTitulo = (dbData['titulo'] ?? "").toString().toLowerCase().trim();
          return dbTitulo == tituloExcel.toLowerCase();
        },
        orElse: () => null,
      );

      if (bookDoc == null) {
        debugPrint("No se encontró el libro '$tituloExcel' en Firebase.");
        continue;
      }

      final String bookId = bookDoc.id;
      final Map<String, dynamic> bookData = bookDoc.data() as Map<String, dynamic>;
      final int stockActual  = bookData['copias']  ?? 0;
      final int estanteActual = bookData['estante'] ?? 0;
      final int almacenActual = bookData['almacen'] ?? 0;

      if (stockActual < cantidad) {
        debugPrint("Stock insuficiente para $tituloExcel ($stockActual < $cantidad)");
        continue;
      }

     
      final int deAlmacen = cantidad <= almacenActual ? cantidad : almacenActual;
      final int deEstante  = cantidad - deAlmacen;

      final nuevaVenta = Sale(
        bookId:         bookId,
        titulo:         tituloExcel,
        autor:          (bookData['autor'] ?? "Desconocido").toString(),
        cantidad:       cantidad,
        fecha:          DateTime.now(),
        userId:         user.uid,
        userEmail:      user.email ?? '',
        lugar:          lugar,
        total:          total,
        precioUnitario: precio,
        deEstante:      deEstante,
        deAlmacen:      deAlmacen,
      );

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final newSaleRef = _salesCollection.doc();
          final bookRef    = _booksCollection.doc(bookId);

          transaction.set(newSaleRef, nuevaVenta.toMap());

          final nuevoStock   = stockActual  - cantidad;
          final nuevoEstante = estanteActual - deEstante;
          final nuevoAlmacen = almacenActual - deAlmacen;

          transaction.update(bookRef, {
            'copias':  nuevoStock,
            'estante': nuevoEstante,
            'almacen': nuevoAlmacen,
            'estado':  nuevoStock > 2,
          });
        });
        debugPrint("Registro exitoso: $tituloExcel");
      } catch (e) {
        debugPrint("Error Firebase: $e");
      }
    }
    debugPrint("Proceso de importación terminado.");
  }

  // ===================================================================
  // AGREGAR VENTA SIMPLE (sin control de origen)
  // ===================================================================
  Future<void> addSale(Sale sale) async {
    try {
      final bookDoc = await _booksCollection.doc(sale.bookId).get();
      if (!bookDoc.exists) throw Exception("El libro no existe");

      final bookData    = bookDoc.data() as Map<String, dynamic>;
      int currentCopies = bookData['copias']  ?? 0;
      int estante       = bookData['estante'] ?? 0;
      int almacen       = bookData['almacen'] ?? 0;

      if (currentCopies < sale.cantidad) {
        throw Exception("No hay copias suficientes");
      }

    
      final int deAlmacen = sale.cantidad <= almacen ? sale.cantidad : almacen;
      final int deEstante  = sale.cantidad - deAlmacen;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(_salesCollection.doc(), sale.toMap());

        final updatedCopies  = currentCopies - sale.cantidad;
        final updatedEstante = estante - deEstante;
        final updatedAlmacen = almacen - deAlmacen;

        transaction.update(_booksCollection.doc(sale.bookId), {
          'copias':  updatedCopies,
          'estante': updatedEstante,
          'almacen': updatedAlmacen,
          'estado':  updatedCopies > 2,
        });
      });
    } catch (e) {
      debugPrint("Error al registrar venta individual: $e");
      rethrow;
    }
  }

  // ===================================================================
  // AGREGAR VENTA CON ORIGEN EXPLÍCITO (estante / almacén / mixto)
  // ===================================================================
  Future<void> addSaleWithOrigin(
      Sale sale, int deEstante, int deAlmacen, BuildContext context) async { // ← agregar context
    try {
      final bookDoc = await _booksCollection.doc(sale.bookId).get();
      if (!bookDoc.exists) throw Exception("El libro no existe");

      final bookData = bookDoc.data() as Map<String, dynamic>;
      final int copias  = bookData['copias']  ?? 0;
      final int estante = bookData['estante'] ?? 0;
      final int almacen = bookData['almacen'] ?? 0;

      if (copias < sale.cantidad) {throw Exception("No hay copias suficientes en el inventario total");}
      if (estante < deEstante) {throw Exception("No hay suficientes copias en estante ($estante disponibles, $deEstante solicitadas)");}
      if (almacen < deAlmacen) {throw Exception("No hay suficientes copias en almacén ($almacen disponibles, $deAlmacen solicitadas)");}

      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(_salesCollection.doc(), sale.toMap());
        final nuevosCopias = copias  - sale.cantidad;
        final nuevoEstante = estante - deEstante;
        final nuevoAlmacen = almacen - deAlmacen;
        tx.update(_booksCollection.doc(sale.bookId), {
          'copias':  nuevosCopias,
          'estante': nuevoEstante,
          'almacen': nuevoAlmacen,
          'estado':  nuevosCopias > 2,
        });
      });

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) Navigator.of(context).pop(); // cierra toast
              if (context.mounted) Navigator.of(context).pop(); // cierra panel
            });
            return CustomToast(
              title:   'Venta registrada',
              message: deEstante > 0 && deAlmacen > 0
                  ? '${sale.cantidad} copia(s) de "${sale.titulo}" ($deEstante estante + $deAlmacen almacén).'
                  : deEstante > 0
                      ? '${sale.cantidad} copia(s) de "${sale.titulo}" desde estante.'
                      : '${sale.cantidad} copia(s) de "${sale.titulo}" desde almacén.',
              color: Colors.green,
              icon:  Icons.check_circle_outline,
            );
          },
        );
      }
    } catch (e) {
      debugPrint("Error al registrar venta con origen: $e");
      rethrow;
    }
  }

  // ===================================================================
  // ACTUALIZAR VENTA
  // ===================================================================
  Future<void> updateSale(Sale sale) async {
    try {
      await _salesCollection.doc(sale.id).update({
        'lugar':          sale.lugar,
        'cantidad':       sale.cantidad,
        'total':          sale.total,
        'precioUnitario': sale.precioUnitario,
      });
    } catch (e) {
      debugPrint('Error al actualizar venta: $e');
      rethrow;
    }
  }

  // ===================================================================
  // STREAM EN TIEMPO REAL
  // ===================================================================
  Stream<List<Sale>> getSalesStream() {
    return _salesCollection
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }

  // ===================================================================
  // CACHÉ LOCAL
  // ===================================================================
  List<Sale> _cachedSales = [];
  int get salesCount => _cachedSales.length;

  Future<void> refreshSalesCache() async {
    try {
      final snapshot = await _salesCollection
          .orderBy('fecha', descending: true)
          .get();
      _cachedSales = snapshot.docs
          .map((doc) =>
              Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error al refrescar caché: $e');
    }
  }

  // ===================================================================
  // EXPORTAR
  // ===================================================================
  Future<List<Map<String, dynamic>>> getAllSalesAsMap() async {
    if (_cachedSales.isEmpty) await refreshSalesCache();
    return _cachedSales.map((sale) => _saleToMap(sale)).toList();
  }

  Future<List<Map<String, dynamic>>> getSelectedSalesAsMap(
      List<Sale> selectedSales) async {
    return selectedSales.map((sale) => _saleToMap(sale)).toList();
  }

  Map<String, dynamic> _saleToMap(Sale s) {
    return {
      'Título':    s.titulo,
      'Autor':     s.autor,
      'Cantidad':  s.cantidad,
      'Fecha':     '${s.fecha.year}-${s.fecha.month.toString().padLeft(2, '0')}-${s.fecha.day.toString().padLeft(2, '0')}',
      'Correo':    s.userEmail,
      'Lugar':     s.lugar,
      'Total':     s.total,
      'Estante':   s.deEstante,
      'Almacén':   s.deAlmacen,
    };
  }
}