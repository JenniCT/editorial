import 'package:cloud_firestore/cloud_firestore.dart';
class Historial {
  final String accion;
  final Map<String, dynamic> cambios;
  final String editadoPor;
  final DateTime fechaEdicion;
  final String idBook;

  Historial({
    required this.accion,
    required this.cambios,
    required this.editadoPor,
    required this.fechaEdicion,
    required this.idBook,
  });

  factory Historial.fromMap(Map<String, dynamic> data) {
    return Historial(
      accion: data['accion'] ?? '',
      cambios: Map<String, dynamic>.from(data['cambios'] ?? {}),
      editadoPor: data['editadoPor'] ?? '',
      fechaEdicion: (data['fechaEdicion'] as Timestamp).toDate(), // 🔥 importante
      idBook: data['idBook'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accion': accion,
      'cambios': cambios,
      'editadoPor': editadoPor,
      'fechaEdicion': fechaEdicion, // Firestore lo guarda como Timestamp
      'idBook': idBook,
    };
  }
}
