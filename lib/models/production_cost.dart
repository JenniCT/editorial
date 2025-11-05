import 'package:cloud_firestore/cloud_firestore.dart';

class CostosProduccion {
  final String id;
  final String idBook;
  final double papelBon;
  final double couchel;
  final double manoObra;
  final double material;
  final double derechosAutor;
  final double isbn;
  final double servicios;
  final double costoExtra1; 
  final double costoExtra2;
  final double costoExtra3; 
  final DateTime fechaRegistro;
  final String registradoPor;

  CostosProduccion({
    required this.id,
    required this.idBook,
    required this.papelBon,
    required this.couchel,
    required this.manoObra,
    required this.material,
    required this.derechosAutor,
    required this.isbn,
    required this.servicios,
    required this.costoExtra1,
    required this.costoExtra2,
    required this.costoExtra3,
    required this.fechaRegistro,
    required this.registradoPor,
  });

  factory CostosProduccion.fromMap(Map<String, dynamic> data, String id) {
    return CostosProduccion(
      id: id,
      idBook: data['idBook'],
      papelBon: (data['papelBon'] ?? 0).toDouble(),
      couchel: (data['couchel'] ?? 0).toDouble(),
      manoObra: (data['manoObra'] ?? 0).toDouble(),
      material: (data['material'] ?? 0).toDouble(),
      derechosAutor: (data['derechosAutor'] ?? 0).toDouble(),
      isbn: (data['isbn'] ?? 0).toDouble(),
      servicios: (data['servicios'] ?? 0).toDouble(),
      costoExtra1: (data['costoExtra1'] ?? 0).toDouble(),
      costoExtra2: (data['costoExtra2'] ?? 0).toDouble(),
      costoExtra3: (data['costoExtra3'] ?? 0).toDouble(),
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
      registradoPor: data['registradoPor'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idBook': idBook,
      'papelBon': papelBon,
      'couchel': couchel,
      'manoObra': manoObra,
      'material': material,
      'derechosAutor': derechosAutor,
      'isbn': isbn,
      'servicios': servicios,
      'costoExtra1': costoExtra1,
      'costoExtra2': costoExtra2,
      'costoExtra3': costoExtra3,
      'fechaRegistro': fechaRegistro,
      'registradoPor': registradoPor,
    };
  }
}
