import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import '../../models/book_m.dart';

class ExportarCSV extends StatelessWidget {
  const ExportarCSV({super.key});

  Future<List<Book>> obtenerLibrosDesdeFirebase() async {
    final snapshot = await FirebaseFirestore.instance.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
  }

  List<List<dynamic>> convertirBooksACSV(List<Book> libros) {
    return [
      [
        'imagenUrl', 'titulo', 'subtitulo', 'autor', 'editorial', 'colección',
        'año', 'isbn', 'edicion', 'copias', 'estante', 'almacen',
        'precio', 'areaConocimiento', 'estado', 'fechaRegistro', 'registradoPor'
      ],
      ...libros.map((book) => [
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
        book.precio.toStringAsFixed(2),
        book.areaConocimiento,
        book.estado ? 'Activo' : 'Inactivo',
        book.fechaRegistro.toIso8601String(),
        book.registradoPor,
      ])
    ];
  }

  pw.Document convertirBooksAPDF(List<Book> libros) {
    final pdf = pw.Document();

    final headers = [
      'imagenUrl', 'titulo', 'subtitulo', 'autor', 'editorial', 'colección',
      'año', 'isbn', 'edicion', 'copias', 'estante', 'almacen',
      'precio', 'areaConocimiento', 'estado', 'fechaRegistro', 'registradoPor'
    ];

    final rows = libros.map((book) => [
      book.imagenUrl ?? '',
      book.titulo,
      book.subtitulo ?? '',
      book.autor,
      book.editorial,
      book.coleccion ?? '',
      book.anio.toString(),
      book.isbn ?? '',
      book.edicion.toString(),
      book.copias.toString(),
      book.estante.toString(),
      book.almacen.toString(),
      book.precio.toStringAsFixed(2),
      book.areaConocimiento,
      book.estado ? 'Activo' : 'Inactivo',
      book.fechaRegistro.toIso8601String(),
      book.registradoPor,
    ]).toList();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: headers,
          data: rows,
          cellStyle: pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );

    return pdf;
  }

  Future<void> seleccionarDestinoYExportar(BuildContext context, String formato) async {
    final output = await FilePicker.platform.getDirectoryPath();
    if (output == null || output.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna carpeta')),
      );
      return;
    }

    final libros = await obtenerLibrosDesdeFirebase();
    if (libros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay libros para exportar')),
      );
      return;
    }

    final fileName = 'inventario_libros';
    final extension = formato == 'csv' ? 'csv' : 'pdf';
    final fullPath = path.join(output, '$fileName.$extension');

    try {
      final file = File(fullPath);
      if (formato == 'csv') {
        final datosCSV = convertirBooksACSV(libros);
        final csv = const ListToCsvConverter().convert(datosCSV);
        await file.writeAsString(csv);
      } else {
        final pdf = convertirBooksAPDF(libros);
        await file.writeAsBytes(await pdf.save());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo $extension guardado en:\n$fullPath')),
      );
    } catch (e, stack) {
      debugPrint('Error al guardar: $e');
      debugPrint('Stacktrace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📤 Exportar Inventario', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Text('Elige el formato y carpeta donde guardar tu archivo.'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.table_chart),
            label: const Text('Exportar como CSV'),
            onPressed: () => seleccionarDestinoYExportar(context, 'csv'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Exportar como PDF'),
            onPressed: () => seleccionarDestinoYExportar(context, 'pdf'),
          ),
        ],
      ),
    );
  }
}