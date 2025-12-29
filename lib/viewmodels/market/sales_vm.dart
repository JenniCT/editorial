import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/sale_m.dart';

class SalesViewModel {
  final CollectionReference _salesCollection =
      FirebaseFirestore.instance.collection('sales');

  final CollectionReference _booksCollection =
      FirebaseFirestore.instance.collection('books');

  /// AGREGA UNA NUEVA VENTA
  Future<void> addSale(Sale sale) async {
    try {
      // Registrar venta
      final saleDoc = await _salesCollection.add(sale.toMap());

      // Obtener datos de libro
      final bookDoc = await _booksCollection.doc(sale.bookId).get();
      if (!bookDoc.exists) {
        debugPrint("Libro con id ${sale.bookId} no existe");
        return;
      }

      final bookData = bookDoc.data() as Map<String, dynamic>;
      int currentCopies = bookData['copias'] ?? 0;

      int updatedCopies = currentCopies - sale.cantidad;
      if (updatedCopies < 0) updatedCopies = 0;

      bool updatedEstado = updatedCopies > 2;

      await _booksCollection.doc(sale.bookId).update({
        'copias': updatedCopies,
        'almacen': updatedCopies,
        'estado': updatedEstado,
      });

      debugPrint("Venta registrada (id: ${saleDoc.id}) y libro actualizado");
    } catch (e) {
      debugPrint("Error al registrar venta: $e");
      rethrow;
    }
  }

  /// STREAM DE VENTAS
  Stream<List<Sale>> getSalesStream() {
    return _salesCollection
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }

  /// STREAM POR LIBRO
  Stream<List<Sale>> getSalesByBook(String bookId) {
    return _salesCollection
        .where('bookId', isEqualTo: bookId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // --------------------- CACHE Y UTILIDADES DE EXPORTACIÓN -------------------
  // ---------------------------------------------------------------------------

  List<Sale> _cachedSales = [];

  int get salesCount => _cachedSales.length;

  Future<void> refreshSalesCache() async {
    try {
      final snapshot = await _salesCollection
          .orderBy('fecha', descending: true)
          .get();

      _cachedSales = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Sale(
          id: doc.id,
          bookId: data['bookId'] ?? '',
          titulo: data['titulo'] ?? '',
          autor: data['autor'] ?? '',
          cantidad: data['cantidad'] ?? 0,
          fecha: (data['fecha'] is Timestamp)
              ? (data['fecha'] as Timestamp).toDate()
              : DateTime.tryParse(data['fecha'] ?? '') ?? DateTime.now(),
          userId: data['userId'] ?? '',
          userEmail: data['userEmail'] ?? '',
          lugar: data['lugar'] ?? 'Desconocido',
          total: (data['total'] is num)
              ? (data['total'] as num).toDouble()
              : 0.0,
        );
      }).toList();
    } catch (e, s) {
      debugPrint('ERROR EN refreshSalesCache: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  Future<List<Map<String, dynamic>>> getAllSalesAsMap() async {
    if (_cachedSales.isEmpty) {
      await refreshSalesCache();
    }
    return _cachedSales.map((sale) => _saleToMap(sale)).toList();
  }

  Future<List<Map<String, dynamic>>> getSelectedSalesAsMap(
      List<Sale> selectedSales) async {
    return selectedSales.map((sale) => _saleToMap(sale)).toList();
  }

  /// 🔥 SOLO LOS CAMPOS QUE PEDISTE PARA EXPORTAR
  Map<String, dynamic> _saleToMap(Sale s) {
    return {
      'Título': s.titulo,
      'Autor': s.autor,
      'Cantidad': s.cantidad,
      'Fecha':
          '${s.fecha.year}-${s.fecha.month.toString().padLeft(2, '0')}-${s.fecha.day.toString().padLeft(2, '0')}',
      'Correo': s.userEmail,
      'Lugar': s.lugar,
      'Total': s.total,
    };
  }
}
