import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? id;
  final File? imagenFile;
  final String? imagenUrl;
  final String titulo;
  final String? subtitulo;
  final String autor;
  final String editorial;
  final String? coleccion;
  final int anio;
  final String? isbn;
  final int edicion;
  final int estante;
  final int almacen;
  final int copias;
  final String areaConocimiento;
  final double precio;
  final bool estado;
  final DateTime fechaRegistro;
  final String registradoPor;
  
  Book({
    this.id,
    this.imagenFile,
    this.imagenUrl,
    required this.titulo,
    this.subtitulo,
    required this.autor,
    required this.editorial,
    this.coleccion,
    required this.anio,
    this.isbn,
    required this.edicion,
    required this.estante,
    required this.almacen,
    required this.copias,
    required this.areaConocimiento,
    required this.precio,
    required this.estado,
    required this.fechaRegistro,
    required this.registradoPor,
  });

  factory Book.fromMap(Map<String, dynamic> map, String documentId) {
    int est = map['estante'] ?? 0;
    int alm = map['almacen'] ?? 0;
    int total = map['copias'] ?? map['totalEjemplares'] ?? (est + alm);

    if (est == 0 && total > 0) est = total - alm;
    if (alm == 0 && total > 0) alm = total - est;

    return Book(
      id: documentId,
      imagenFile: null,
      imagenUrl: map['imagenUrl'] as String?,
      titulo: map['titulo'] ?? '',
      subtitulo: map['subtitulo'] as String?,
      autor: map['autor'] ?? '',
      editorial: map['editorial'] ?? '',
      coleccion: map['coleccion'] as String?,
      anio: (map['anio'] is int) ? map['anio'] : int.tryParse(map['anio'].toString()) ?? 0,
      isbn: map['isbn'] as String?,
      edicion: (map['edicion'] is int) ? map['edicion'] : int.tryParse(map['edicion'].toString()) ?? 1,
      estante: est,
      almacen: alm,
      copias: total,
      areaConocimiento: map['areaConocimiento'] ?? 'Sin definir',
      precio: (map['precio'] is double) ? map['precio'] : double.tryParse(map['precio'].toString()) ?? 0.0,
      estado: map['estado'] ?? true,
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
      registradoPor: map['registradoPor'] ?? 'desconocido',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imagenUrl': imagenUrl,
      'titulo': titulo,
      'subtitulo': subtitulo,
      'autor': autor,
      'editorial': editorial,
      'coleccion': coleccion,
      'anio': anio,
      'isbn': isbn,
      'edicion': edicion,
      'estante': estante,
      'almacen': almacen,
      'copias': copias,
      'areaConocimiento': areaConocimiento,
      'precio': precio,
      'estado': estado,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'registradoPor': registradoPor,
    };
  }

  Book copyWith({
    String? id,
    File? imagenFile,
    String? imagenUrl,
    String? titulo,
    String? subtitulo,
    String? autor,
    String? editorial,
    String? coleccion,
    int? anio,
    String? isbn,
    int? edicion,
    int? estante,
    int? almacen,
    int? copias,
    String? areaConocimiento,
    double? precio,
    bool? estado,
    DateTime? fechaRegistro,
    String? registradoPor,
  }) {
    return Book(
      id: id ?? this.id,
      imagenFile: imagenFile ?? this.imagenFile,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      autor: autor ?? this.autor,
      editorial: editorial ?? this.editorial,
      coleccion: coleccion ?? this.coleccion,
      anio: anio ?? this.anio,
      isbn: isbn ?? this.isbn,
      edicion: edicion ?? this.edicion,
      estante: estante ?? this.estante,
      almacen: almacen ?? this.almacen,
      copias: copias ?? this.copias,
      areaConocimiento: areaConocimiento ?? this.areaConocimiento,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      registradoPor: registradoPor ?? this.registradoPor,
    );
  }
  String bookToQrData(Book book) {
  final data = {
    'Título': book.titulo,
    'Autor': book.autor,
    'Editorial': book.editorial,
    'Año': book.anio,
    'ISBN': book.isbn ?? 'Sin ISBN',
    'Área': book.areaConocimiento,
    'Copias': book.copias,
    'Registrado por': book.registradoPor,
  };

  return data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
}
}