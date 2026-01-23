import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/sale_m.dart';

class SalesViewModel {
  final CollectionReference _salesCollection =
      FirebaseFirestore.instance.collection('sales');
  final CollectionReference _booksCollection =
      FirebaseFirestore.instance.collection('books');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> importSalesFromExcel(List<Map<String, dynamic>> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Sesión no activa");

    debugPrint("🚀 Iniciando importación de ${data.length} filas...");

    final booksSnapshot = await _booksCollection.get();
    final allBooks = booksSnapshot.docs;

    for (var row in data) {
      // 1. EXTRAER VALORES CON AYUDA DE BUSQUEDA FLEXIBLE
      // Intentamos obtener el título buscando en llaves comunes si la principal falla
      String tituloExcel = (row['Título'] ?? row['titulo'] ?? row['TITULO'] ?? "").toString().trim();
      
      // Si el título es igual al nombre de la columna, es la fila de encabezado del Excel. Saltamos.
      if (tituloExcel.isEmpty || tituloExcel.toLowerCase() == "título" || tituloExcel.toLowerCase() == "titulo") {
        debugPrint("⏭️ Fila de encabezado o vacía detectada ('$tituloExcel'). Saltando...");
        continue;
      }

      int cantidad = int.tryParse((row['Cantidad'] ?? row['cantidad'] ?? "0").toString()) ?? 0;
      double total = double.tryParse((row['Total'] ?? row['total'] ?? "0").toString()) ?? 0.0;
      String lugar = (row['Lugar'] ?? row['lugar'] ?? "FIL UNACH").toString().trim();

      debugPrint("🔍 Procesando: '$tituloExcel' | Cantidad: $cantidad | Total: $total");

      if (cantidad <= 0) {
        debugPrint("⚠️ Cantidad inválida para '$tituloExcel'. Saltando...");
        continue;
      }

      // 2. BUSCAR EL LIBRO EN FIRESTORE
      final bookDoc = allBooks.cast<QueryDocumentSnapshot?>().firstWhere(
        (doc) {
          final dbData = doc?.data() as Map<String, dynamic>;
          final dbTitulo = (dbData['titulo'] ?? "").toString().toLowerCase().trim();
          return dbTitulo == tituloExcel.toLowerCase();
        },
        orElse: () => null,
      );

      if (bookDoc == null) {
        debugPrint("❌ No se encontró el libro '$tituloExcel' en Firebase.");
        continue;
      }

      final String bookId = bookDoc.id;
      final Map<String, dynamic> bookData = bookDoc.data() as Map<String, dynamic>;
      final int stockActual = (bookData['copias'] ?? 0);

      if (stockActual < cantidad) {
        debugPrint("🚫 Stock insuficiente para $tituloExcel ($stockActual < $cantidad)");
        continue;
      }

      // 3. REGISTRAR VENTA
      final nuevaVenta = Sale(
        bookId: bookId,
        titulo: tituloExcel,
        autor: (bookData['autor'] ?? "Desconocido").toString(),
        cantidad: cantidad,
        fecha: DateTime.now(),
        userId: user.uid,
        userEmail: user.email ?? '',
        lugar: lugar,
        total: total,
      );

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final newSaleRef = _salesCollection.doc();
          final bookRef = _booksCollection.doc(bookId);

          transaction.set(newSaleRef, nuevaVenta.toMap());

          int nuevoStock = stockActual - cantidad;
          transaction.update(bookRef, {
            'copias': nuevoStock,
            'almacen': nuevoStock,
            'estado': nuevoStock > 2,
          });
        });
        debugPrint("✅ REGISTRO EXITOSO: $tituloExcel");
      } catch (e) {
        debugPrint("❌ ERROR FIRESTORE: $e");
      }
    }
    debugPrint("🏁 Proceso terminado.");
  }

  // MÉTODOS ADICIONALES (addSale, getSalesStream, etc.)
  Future<void> addSale(Sale sale) async {
    try {
      final bookDoc = await _booksCollection.doc(sale.bookId).get();
      if (!bookDoc.exists) throw Exception("El libro no existe");
      final bookData = bookDoc.data() as Map<String, dynamic>;
      int currentCopies = bookData['copias'] ?? 0;
      if (currentCopies < sale.cantidad) throw Exception("No hay copias suficientes");

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(_salesCollection.doc(), sale.toMap());
        int updatedCopies = currentCopies - sale.cantidad;
        transaction.update(_booksCollection.doc(sale.bookId), {
          'copias': updatedCopies,
          'almacen': updatedCopies,
          'estado': updatedCopies > 2,
        });
      });
    } catch (e) {
      debugPrint("Error al registrar venta individual: $e");
      rethrow;
    }
  }

  Stream<List<Sale>> getSalesStream() {
    return _salesCollection.orderBy('fecha', descending: true).snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id)).toList());
  }

  List<Sale> _cachedSales = [];
  int get salesCount => _cachedSales.length;

  Future<void> refreshSalesCache() async {
    try {
      final snapshot = await _salesCollection.orderBy('fecha', descending: true).get();
      _cachedSales = snapshot.docs.map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id)).toList();
    } catch (e) { debugPrint('ERROR Cache: $e'); }
  }

  Future<List<Map<String, dynamic>>> getAllSalesAsMap() async {
    if (_cachedSales.isEmpty) await refreshSalesCache();
    return _cachedSales.map((sale) => _saleToMap(sale)).toList();
  }

  Future<List<Map<String, dynamic>>> getSelectedSalesAsMap(List<Sale> selectedSales) async {
    return selectedSales.map((sale) => _saleToMap(sale)).toList();
  }

  Map<String, dynamic> _saleToMap(Sale s) {
    return {
      'Título': s.titulo, 'Autor': s.autor, 'Cantidad': s.cantidad,
      'Fecha': '${s.fecha.year}-${s.fecha.month.toString().padLeft(2, '0')}-${s.fecha.day.toString().padLeft(2, '0')}',
      'Correo': s.userEmail, 'Lugar': s.lugar, 'Total': s.total,
    };
  }
}