import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import '../../models/book_m.dart';

class ExportadorCSVViewModel {
  List<Book>? libros;
  bool loading = false;
  String? error;

  // OBTENER LIBROS DE FIRESTORE (robusto)
  Future<void> obtenerLibros() async {
    loading = true;
    error = null;
    libros = [];
    List<String> erroresLibros = [];

    try {
      final snapshot = await FirebaseFirestore.instance.collection('books').get();

      for (var doc in snapshot.docs) {
        try {
          final book = Book.fromMap(doc.data(), doc.id);
          libros!.add(book);
        } catch (e) {
          erroresLibros.add('Error en documento ${doc.id}: $e');
        }
      }

      // Ordenar por título
      libros?.sort((a, b) => a.tituloLower.compareTo(b.tituloLower));

      if (erroresLibros.isNotEmpty) {
        error = 'Algunos libros no se cargaron correctamente:\n${erroresLibros.join('\n')}';
      }
    } catch (e) {
      error = 'Error al obtener libros de Firestore: $e';
    } finally {
      loading = false;
    }
  }

  // CONVERTIR LIBROS A CSV
  List<List<dynamic>> convertirBooksACSV() {
    if (libros == null || libros!.isEmpty) return [];

    return [
      [
        'Portada',
        'Título',
        'Subtítulo',
        'Autor',
        'Editorial',
        'Colección',
        'Año',
        'ISBN',
        'Edición',
        'Copias',
        'Estante',
        'Almacén',
        'Área de conocimiento',
        'Estado',
      ],
      ...libros!.map((book) => [
            book.imagenUrl ?? '',
            book.titulo,
            book.subtitulo ?? '',
            book.autor,
            book.editorial,
            book.coleccion ?? '',
            book.anio,
            book.isbn ?? '',
            book.edicion,
            book.copias,
            book.estante,
            book.almacen,
            book.areaConocimiento,
            book.estado ? 'Inventario' : 'Acervo',
          ])
    ];
  }

  // SELECCIONAR CARPETA Y EXPORTAR CSV
  Future<void> exportarCSV(BuildContext context) async {
    if (libros == null || libros!.isEmpty) {
      error = 'No hay libros para exportar.';
      return;
    }

    final output = await FilePicker.platform.getDirectoryPath();
    if (output == null || output.isEmpty) {
      error = 'No se seleccionó ninguna carpeta.';
      return;
    }

    final fullPath = '$output/inventario_libros.csv';

    try {
      final csv = const ListToCsvConverter().convert(convertirBooksACSV());

      final file = File(fullPath);
      final bom = '\ufeff';
      await file.writeAsString('$bom$csv', encoding: utf8);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo CSV guardado en:\n$fullPath')),
        );
      }
    } catch (e) {
      error = 'Error al exportar: $e';
    }
  }
}
