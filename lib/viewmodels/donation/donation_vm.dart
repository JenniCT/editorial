import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/donation_m.dart';
import '../../widgets/global/dialog.dart';

class DonationsViewModel {
  final CollectionReference _donationsCollection =
      FirebaseFirestore.instance.collection('donations');

  final CollectionReference _booksCollection = FirebaseFirestore.instance.collection('books');

  final List<Donation> donations = [];

  // ===================================================================
  // CARGAR DONACIONES
  // ===================================================================
  void loadDonationsFromSnapshot(QuerySnapshot snapshot) {
    donations.clear();
    for (var doc in snapshot.docs) {
      donations.add(
        Donation.fromMap(doc.data() as Map<String, dynamic>, id: doc.id),
      );
    }
  }

  // ===================================================================
  // SELECCIÓN
  // ===================================================================
  void toggleSelect(String id) {
    final index = donations.indexWhere((d) => d.id == id);
    if (index != -1) donations[index].selected = !donations[index].selected;
  }

  void clearSelection() {
    for (var d in donations){ d.selected = false;}
  }

  // ===================================================================
  // AGREGAR DONACIÓN CON ORIGEN EXPLÍCITO (estante / almacén / mixto)
  // Espejo exacto de addSaleWithOrigin en SalesViewModel.
  // ===================================================================
  Future<void> addDonationWithOrigin(
      Donation donation, int deEstante, int deAlmacen, BuildContext context) async {
    try {
      final bookDoc = await _booksCollection.doc(donation.bookId).get();
      if (!bookDoc.exists) throw Exception('El libro no existe');

      final bookData    = bookDoc.data() as Map<String, dynamic>;
      final int copias  = bookData['copias']  ?? 0;
      final int estante = bookData['estante'] ?? 0;
      final int almacen = bookData['almacen'] ?? 0;

      if (copias < donation.cantidad) {throw Exception('No hay copias suficientes en el inventario total');}
      if (estante < deEstante) {throw Exception('No hay suficientes copias en estante');}
      if (almacen < deAlmacen) {throw Exception('No hay suficientes copias en almacén');}

      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(_donationsCollection.doc(), donation.toMap());
        final nuevosCopias = copias  - donation.cantidad;
        final nuevoEstante = estante - deEstante;
        final nuevoAlmacen = almacen - deAlmacen;
        tx.update(_booksCollection.doc(donation.bookId), {
          'copias':  nuevosCopias,
          'estante': nuevoEstante,
          'almacen': nuevoAlmacen,
          'estado':  nuevosCopias > 2,
        });
      });

      // ── Igual que acervo ──────────────────────────────────────────────
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) Navigator.of(context).pop(); // cierra el toast
              if (context.mounted) Navigator.of(context).pop(); // cierra el panel
            });
            return CustomToast(
              title:   'Donación registrada',
              message: deEstante > 0 && deAlmacen > 0
                  ? '${donation.cantidad} copia(s) de "${donation.titulo}").'
                  : deEstante > 0
                      ? '${donation.cantidad} copia(s) de "${donation.titulo}" desde estante.'
                      : '${donation.cantidad} copia(s) de "${donation.titulo}" desde almacén.',
              color: Colors.green,
              icon:  Icons.check_circle_outline,
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error al registrar donación con origen: $e');
      rethrow;
    }
  }
  // ===================================================================
  // STREAMS
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
  // CACHÉ LOCAL
  // ===================================================================
  List<Donation> _cachedDonations = [];
  int get donationsCount => _cachedDonations.length;

  Future<void> refreshDonationsCache() async {
    try {
      final snapshot = await _donationsCollection
          .orderBy('fecha', descending: true)
          .get();
      _cachedDonations = snapshot.docs
          .map((doc) =>
              Donation.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error al refrescar caché: $e');
    }
  }



  // ===================================================================
  // ACTUALIZAR
  // ===================================================================
  Future<void> updateDonation(Donation donation) async {
    try {
      await _donationsCollection.doc(donation.id).update({
        'lugar':    donation.lugar,
        'cantidad': donation.cantidad,
        'nota':     donation.nota,
      });
    } catch (e) {
      debugPrint('Error al actualizar donación: $e');
      rethrow;
    }
  }

  // ===================================================================
  // EXPORTACIÓN
  // ===================================================================

  Map<String, dynamic> _donationToMap(Donation d) => {
        'Titulo':   d.titulo,
        'Autor':    d.autor,
        'Cantidad': d.cantidad,
        'Fecha':    d.fecha.toIso8601String(),
        'Correo':   d.userEmail,
        'Lugar':    d.lugar,
        'Nota':     d.nota ?? '',
        'Estante':  d.deEstante,
        'Almacén':  d.deAlmacen,
      };

  List<Map<String, dynamic>> getAllDonationsAsMap() =>
      donations.map(_donationToMap).toList();

  List<Map<String, dynamic>> getSelectedDonationsAsMap(
          List<Donation> selected) =>
      selected.map(_donationToMap).toList();
}