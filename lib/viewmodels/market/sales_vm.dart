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

      // Copias restantes
      int updatedCopies = currentCopies - sale.cantidad;
      if (updatedCopies < 0) updatedCopies = 0;

      // Determinar estado (ejemplo: activo si quedan más de 2 copias)
      bool updatedEstado = updatedCopies > 2;

      // Actualizar datos del libro
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

  /// VISUALIZAR TODAS LAS VENTAS
  Stream<List<Sale>> getSalesStream() {
    return _salesCollection
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }

  /// VENTAS POR LIBRO
  Stream<List<Sale>> getSalesByBook(String bookId) {
    return _salesCollection
        .where('bookId', isEqualTo: bookId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }
}
