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

  //OBTENER LIBROS DE FIREBASE
  Future<void> obtenerLibros() async {
    loading = true;
    error = null;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('books').get();
      libros = snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();

      libros?.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
    } catch (e) {
      error = 'Error al obtener libros: $e';
      libros = null;
    } finally {
      loading = false;
    }
  }

  ///CONVERTIR LIBROS A CSV
  List<List<dynamic>> convertirBooksACSV() {
    if (libros == null || libros!.isEmpty) return [];
    return [
      [
        'Portada', 'Título', 'Subtítulo', 'Autor', 'Editorial', 'Colección',
        'Año', 'ISBN', 'Edición', 'Copias', 'Precio', 'Estante', 'Almacén',
        'Área de conocimiento', 'Estado', 'Fecha de Registro', 'Registrado por'
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
        book.precio.toStringAsFixed(2),
        book.estante,
        book.almacen,
        book.areaConocimiento,
        book.estado ? 'Inventario' : 'Acervo',
        book.fechaRegistro.toIso8601String(),
        book.registradoPor,
      ])
    ];
  }

  //SELECCIONAR CARPETA Y EXPORTAR CSV 
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

      // --- Forzar UTF-8 con BOM para caracteres especiales
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
