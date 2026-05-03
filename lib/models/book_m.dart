import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? id;
  final File? imagenFile;
  final String? imagenUrl;
  final String titulo;
  final String tituloLower;
  final String? subtitulo;
  final String autor;
  final String autorLower;
  final String editorial;
  final String editorialLower;
  final String? coleccion;
  final int anio;
  final String? isbn;
  final int edicion;
  final int estante;
  final int almacen;
  final int copias;
  final String areaConocimiento;
  final String areaLower;
  final bool estado;
  final DateTime fechaRegistro;
  final String registradoPor;
  // NUEVOS CAMPOS DE MODIFICACIÓN
  final DateTime? fechaModificacion;
  final String? modificadoPor;
  bool selected = false;

  Book({
    this.id,
    this.imagenFile,
    this.imagenUrl,
    required this.titulo,
    required this.autor,
    required this.editorial,
    required this.areaConocimiento,
    this.subtitulo,
    this.coleccion,
    required this.anio,
    this.isbn,
    required this.edicion,
    required this.estante,
    required this.almacen,
    required this.copias,
    this.estado = true,
    required this.fechaRegistro,
    required this.registradoPor,
    this.fechaModificacion,
    this.modificadoPor,
    this.selected = false,
  })  : tituloLower = titulo.toLowerCase(),
        autorLower = autor.toLowerCase(),
        editorialLower = editorial.toLowerCase(),
        areaLower = areaConocimiento.toLowerCase();

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
      anio: (map['anio'] is int)
          ? map['anio']
          : int.tryParse(map['anio'].toString()) ?? 0,
      isbn: map['isbn'] as String?,
      edicion: (map['edicion'] is int)
          ? map['edicion']
          : int.tryParse(map['edicion'].toString()) ?? 1,
      estante: est,
      almacen: alm,
      copias: total,
      areaConocimiento: map['areaConocimiento'] ?? 'Sin definir',
      estado: map['estado'] ?? true,
      fechaRegistro: (map['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registradoPor: map['registradoPor'] ?? 'desconocido',
      fechaModificacion: (map['fechaModificacion'] as Timestamp?)?.toDate(),
      modificadoPor: map['modificadoPor'] as String?,
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
      'estado': estado,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'registradoPor': registradoPor,
      if (fechaModificacion != null)
        'fechaModificacion': Timestamp.fromDate(fechaModificacion!),
      if (modificadoPor != null) 'modificadoPor': modificadoPor,
    };
  }

  Book copyWith({
    String? id,
    File? imagenFile,
    bool clearImagenFile = false,
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
    bool? estado,
    DateTime? fechaRegistro,
    String? registradoPor,
    DateTime? fechaModificacion,
    String? modificadoPor,
    bool? selected,
  }) {
    return Book(
      id: id ?? this.id,
      // SI clearImagenFile=true SE LIMPIA, SI SE PASA imagenFile SE USA, SI NO SE MANTIENE
      imagenFile: clearImagenFile ? null : (imagenFile ?? this.imagenFile),
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
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      registradoPor: registradoPor ?? this.registradoPor,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      modificadoPor: modificadoPor ?? this.modificadoPor,
      selected: selected ?? this.selected,
    );
  }

  String bookToQrData(Book book) {
    return [
      'Título: ${book.titulo}',
      'Subtítulo: ${book.subtitulo}',
      'Autor: ${book.autor}',
      'Editorial: ${book.editorial}',
      'Año: ${book.anio}',
      'ISBN: ${book.isbn ?? 'Sin ISBN'}',
      'Área: ${book.areaConocimiento}',
      'Copias: ${book.copias}',
      'Estante: ${book.estante}',
      'Almacén: ${book.almacen}',
      'Registrado por: ${book.registradoPor}',
    ].join('\n');
  }
}