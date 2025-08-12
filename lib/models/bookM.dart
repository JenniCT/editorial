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
  final int copias;
  final double precio;
  final String formato;
  final bool estado;
  final DateTime fechaRegistro;

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
    required this.copias,
    required this.precio,
    required this.formato,
    required this.estado,
    required this.fechaRegistro,
  });

  factory Book.fromMap(Map<String, dynamic> map, String documentId) {
    return Book(
      id: documentId,
      imagenFile: null,  // No se puede recuperar la imagenFile desde Firestore
      imagenUrl: map['imagenUrl'] as String?,
      titulo: map['titulo'] ?? '',
      subtitulo: map['subtitulo'] as String?,
      autor: map['autor'] ?? '',
      editorial: map['editorial'] ?? '',
      coleccion: map['coleccion'] as String?,
      anio: (map['anio'] is int) ? map['anio'] : int.tryParse(map['anio'].toString()) ?? 0,
      isbn: map['isbn'] as String?,
      edicion: (map['edicion'] is int) ? map['edicion'] : int.tryParse(map['edicion'].toString()) ?? 1,
      copias: (map['copias'] is int) ? map['copias'] : int.tryParse(map['copias'].toString()) ?? 1,
      precio: (map['precio'] is double) ? map['precio'] : double.tryParse(map['precio'].toString()) ?? 0.0,
      formato: map['formato'] ?? '',
      estado: map['estado'] ?? true,
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
    );
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
    int? copias,
    double? precio,
    String? formato,
    bool? estado,
    DateTime? fechaRegistro,
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
      copias: copias ?? this.copias,
      precio: precio ?? this.precio,
      formato: formato ?? this.formato,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      //'id': id, // no se recomienda guardar el id como campo aparte
      'imagenUrl': imagenUrl,
      'titulo': titulo,
      'subtitulo': subtitulo,
      'autor': autor,
      'editorial': editorial,
      'coleccion': coleccion,
      'anio': anio,
      'isbn': isbn,
      'edicion': edicion,
      'copias': copias,
      'precio': precio,
      'formato': formato,
      'estado': estado,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }
}
