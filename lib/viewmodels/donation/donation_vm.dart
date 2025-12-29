import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/donation_m.dart';

class DonationsViewModel {
  final CollectionReference _donationsCollection =
      FirebaseFirestore.instance.collection('donations');

  final CollectionReference _booksCollection =
      FirebaseFirestore.instance.collection('books');

  /// Lista local para manejo en exportación y selección
  final List<Donation> donations = [];

  // ===================================================================
  // CARGAR DONACIONES Y GUARDARLAS LOCALMENTE PARA EXPORTACIÓN
  // ===================================================================
  void loadDonationsFromSnapshot(QuerySnapshot snapshot) {
    donations.clear();
    for (var doc in snapshot.docs) {
      donations.add(
        Donation.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        ),
      );
    }
  }

  // ===================================================================
  // SELECCIÓN DE FILAS
  // ===================================================================
  void toggleSelect(String id) {
    final index = donations.indexWhere((d) => d.id == id);
    if (index != -1) {
      donations[index].selected = !donations[index].selected;
    }
  }

  void clearSelection() {
    for (var d in donations) {
      d.selected = false;
    }
  }

  // ===================================================================
  // AGREGA UNA NUEVA DONACIÓN
  // ===================================================================
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

      // Copias restantes
      int updatedCopies = currentCopies - donation.cantidad;
      if (updatedCopies < 0) updatedCopies = 0;

      // Determinar estado del libro (tu regla: true = disponible)
      bool updatedEstado = updatedCopies > 2;

      // Actualizar inventario
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

  // ===================================================================
  // STREAM DE TODAS LAS DONACIONES (CARGA + MODELO)
  // ===================================================================
  Stream<List<Donation>> getDonationsStream() {
    return _donationsCollection
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      loadDonationsFromSnapshot(snapshot);
      return donations;
    });
  }

  // ===================================================================
  // DONACIONES POR LIBRO
  // ===================================================================
  Stream<List<Donation>> getDonationsByBook(String bookId) {
    return _donationsCollection
        .where('bookId', isEqualTo: bookId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Donation.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
          .toList();
    });
  }

  // ===================================================================
  // CANTIDAD TOTAL DE DONACIONES (PARA EXPORTAR O DIALOG)
  // ===================================================================
  int get donationsCount => donations.length;

  // ===================================================================
  // MAP PARA EXPORTAR (SOLO CAMPOS VISIBLES)
  // ===================================================================
  Map<String, dynamic> _donationToMap(Donation d) {
    return {
      'Titulo': d.titulo,
      'Autor': d.autor,
      'Cantidad': d.cantidad,
      'Fecha': d.fecha.toIso8601String(),
      'Correo': d.userEmail,
      'Lugar': d.lugar,
      'Nota': d.nota ?? '',
    };
  }

  // ===================================================================
  // EXPORTAR TODAS LAS DONACIONES
  // ===================================================================
  List<Map<String, dynamic>> getAllDonationsAsMap() {
    return donations.map(_donationToMap).toList();
  }

  // ===================================================================
  // EXPORTAR SOLO SELECCIONADAS
  // ===================================================================
  List<Map<String, dynamic>> getSelectedDonationsAsMap(List<Donation> selected) {
    return selected.map((d) {
      return {
        'titulo': d.titulo,
        'autor': d.autor,
        'cantidad': d.cantidad,
        'fecha': d.fecha.toIso8601String(),
        'userEmail': d.userEmail,
        'lugar': d.lugar,
        'nota': d.nota ?? '',
      };
    }).toList();
  }
}
