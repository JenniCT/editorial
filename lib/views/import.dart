import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book_m.dart';

class ImportadorCSV extends StatefulWidget {
  const ImportadorCSV({super.key});

  @override
  State<ImportadorCSV> createState() => _ImportadorCSVState();
}

class _ImportadorCSVState extends State<ImportadorCSV> {
  List<List<dynamic>>? datosCSV;
  String? error;

  String limpiarUrl(dynamic valor) {
    final url = valor?.toString().trim() ?? '';
    return url.startsWith('http') ? url : '';
  }

  Future<void> importarCSV() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (resultado == null || resultado.files.isEmpty) return;

      final path = resultado.files.single.path!;
      final bytes = await File(path).readAsBytes();
      final contenido = utf8.decode(bytes);

      final csv = const CsvToListConverter().convert(contenido);
      setState(() {
        datosCSV = csv;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = '❌ Error al leer el archivo: $e';
        datosCSV = null;
      });
    }
  }

  Future<void> subirDatosAFirestore() async {
    if (datosCSV == null || datosCSV!.length < 2) {
      setState(() {
        error = '⚠️ No hay datos para subir';
      });
      return;
    }

    final encabezados = datosCSV!.first.map((e) => e.toString().trim()).toList();
    final registros = datosCSV!.skip(1);
    final email = FirebaseAuth.instance.currentUser?.email ?? 'desconocido';

    int subidos = 0;

    for (var fila in registros) {
      final mapa = <String, dynamic>{};
      for (int i = 0; i < encabezados.length; i++) {
        mapa[encabezados[i]] = fila[i];
      }

      try {
        final book = Book(
          imagenUrl: limpiarUrl(mapa['imagenUrl']),
          titulo: mapa['titulo']?.toString() ?? '',
          subtitulo: mapa['subtitulo']?.toString(),
          autor: mapa['autor']?.toString() ?? '',
          editorial: mapa['editorial']?.toString() ?? '',
          coleccion: mapa['coleccion']?.toString(),
          anio: int.tryParse(mapa['anio']?.toString() ?? '') ?? 0,
          isbn: mapa['isbn']?.toString(),
          edicion: int.tryParse(mapa['edicion']?.toString() ?? '') ?? 1,
          copias: int.tryParse(mapa['copias']?.toString() ?? '') ?? 1,
          estante: int.tryParse(mapa['estante']?.toString() ?? '') ?? 0,
          almacen: int.tryParse(mapa['almacen']?.toString() ?? '') ?? 0,
          precio: double.tryParse(mapa['precio']?.toString() ?? '') ?? 0.0,
          areaConocimiento: mapa['areaConocimiento']?.toString() ?? 'Sin definir',
          estado: true,
          fechaRegistro: DateTime.now(),
          registradoPor: email,
        );

        await FirebaseFirestore.instance.collection('books').add(book.toMap());
        subidos++;
      } catch (e) {
        debugPrint('❌ Error al subir fila: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ $subidos libros subidos exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📚 Importar libros desde CSV', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Seleccionar archivo CSV'),
            onPressed: importarCSV,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Subir a Firestore'),
            onPressed: subirDatosAFirestore,
          ),
          const SizedBox(height: 20),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          if (datosCSV != null)
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: datosCSV!.length,
                itemBuilder: (context, index) {
                  final fila = datosCSV![index];
                  return ListTile(
                    dense: true,
                    title: Text(fila.join(', ')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}