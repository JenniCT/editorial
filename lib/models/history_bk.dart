import 'package:cloud_firestore/cloud_firestore.dart';

class Historial {
  final String idLibro;
  final String editadoPor;
  final DateTime fechaEdicion;
  final Map<String, dynamic> cambios;

  Historial({
    required this.idLibro,
    required this.editadoPor,
    required this.fechaEdicion,
    required this.cambios,
  });

  factory Historial.fromMap(Map<String, dynamic> map) {
    return Historial(
      idLibro: map['idLibro'],
      editadoPor: map['editadoPor'],
      fechaEdicion: (map['fechaEdicion'] as Timestamp).toDate(),
      cambios: Map<String, dynamic>.from(map['cambios']),
    );
  }
}