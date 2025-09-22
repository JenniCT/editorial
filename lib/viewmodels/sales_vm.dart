import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/sale_m.dart';

class SalesViewModel {
  final CollectionReference _salesCollection =
      FirebaseFirestore.instance.collection('sales');

  final CollectionReference _booksCollection =
      FirebaseFirestore.instance.collection('books');

  //AGREGA UNA NUEVA VENTA 
  Future<void> addSale(Sale sale) async {
    try {

      // SE OBTIENE DATOS DE LIBRO
      final bookDoc = await _booksCollection.doc(sale.bookId).get();
      if (!bookDoc.exists) {
        debugPrint('El libro con id ${sale.bookId} no existe');
        return;
      }

      final bookData = bookDoc.data() as Map<String, dynamic>;
      int currentCopies = bookData['copias'] ?? 0;

      //COPIAS RESTANTES
      int updatedCopies = currentCopies - sale.cantidad;
      if (updatedCopies < 0) updatedCopies = 0;

      //DETERMINAR ACERVO O INVENTARIO
      bool updatedEstado = updatedCopies > 2;

      //ACTUALIZA LOS DATOS DEL LIBRO
      await _booksCollection.doc(sale.bookId).update({
        'copias': updatedCopies,
        'almacen': updatedCopies,
        'estado': updatedEstado,
      });

      debugPrint('Venta registrada y libro actualizado correctamente');
    } catch (e) {
      debugPrint('Error al registrar la venta o actualizar libro: $e');
      rethrow;
    }
  }

  /// VISUALIZAR TODAS LAS VENTAS
  Stream<List<Sale>> getSalesStream() {
    return _salesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id)).toList());
  }

  /// VENTAS POR LIBRO
  Stream<List<Sale>> getSalesByBook(String bookId) {
    return _salesCollection
        .where('bookId', isEqualTo: bookId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }
}
