import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/donation_m.dart';


class DonationsViewModel {
  final CollectionReference _donationsCollection =
      FirebaseFirestore.instance.collection('donations');

  final CollectionReference _booksCollection =
      FirebaseFirestore.instance.collection('books');

  /// AGREGA UNA NUEVA DONACIÓN
  Future<void> addDonation(Donation donation) async {
    try {
      // Registrar donación
      final donationDoc = await _donationsCollection.add(donation.toMap());

      // Obtener libro
      final bookDoc = await _booksCollection.doc(donation.bookId).get();
      if (!bookDoc.exists) {
        debugPrint("Libro con id ${donation.bookId} no existe");
        return;
      }

      final bookData = bookDoc.data() as Map<String, dynamic>;
      int currentCopies = bookData['copias'] ?? 0;

      // Copias restantes (si deseas actualizar inventario)
      int updatedCopies = currentCopies - donation.cantidad;
      if (updatedCopies < 0) updatedCopies = 0;

      // Determinar estado del libro
      bool updatedEstado = updatedCopies > 2;

      // Actualizar datos del libro
      await _booksCollection.doc(donation.bookId).update({
        'copias': updatedCopies,
        'almacen': updatedCopies,
        'estado': updatedEstado,
      });

      debugPrint("Donación registrada (id: ${donationDoc.id}) y libro actualizado");
    } catch (e) {
      debugPrint("Error al registrar donación: $e");
      rethrow;
    }
  }

  /// STREAM DE TODAS LAS DONACIONES
  Stream<List<Donation>> getDonationsStream() {
    return _donationsCollection
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Donation.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }

  /// DONACIONES POR LIBRO
  Stream<List<Donation>> getDonationsByBook(String bookId) {
    return _donationsCollection
        .where('bookId', isEqualTo: bookId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Donation.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList());
  }
}
