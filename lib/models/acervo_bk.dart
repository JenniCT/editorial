import 'dart:io';

class Acervo {
  final String? id;
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
  final String? imagenUrl;
  final File? imagenFile;
  final bool estado;
  final DateTime fechaRegistro;
  final String areaConocimiento;
  final String registradoPor;

  Acervo({
    this.id,
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
    this.imagenUrl,
    this.imagenFile,
    this.estado = true,
    required this.fechaRegistro,
    required this.areaConocimiento,
    required this.registradoPor,
  });

  Map<String, dynamic> toMap() {
    return {
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
      'imagenUrl': imagenUrl,
      'estado': estado,
      'fechaRegistro': fechaRegistro,
      'areaConocimiento': areaConocimiento,
      'registradoPor': registradoPor,
    };
  }

  Acervo copyWith({
    String? id,
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
    String? imagenUrl,
    File? imagenFile,
    bool? estado,
    DateTime? fechaRegistro,
    String? areaConocimiento,
    String? registradoPor,
  }) {
    return Acervo(
      id: id ?? this.id,
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
      imagenUrl: imagenUrl ?? this.imagenUrl,
      imagenFile: imagenFile ?? this.imagenFile,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      areaConocimiento: areaConocimiento ?? this.areaConocimiento,
      registradoPor: registradoPor ?? this.registradoPor,
    );
  }
}
