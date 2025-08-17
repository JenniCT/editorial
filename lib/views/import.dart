import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bookM.dart';

class ImportarCSVDialog extends StatefulWidget {
  @override
  _ImportarCSVDialogState createState() => _ImportarCSVDialogState();
}

class _ImportarCSVDialogState extends State<ImportarCSVDialog> {
  List<List<dynamic>>? datosCSV;
  String? error;

  Future<void> importarCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final rows = const CsvToListConverter().convert(content);

        setState(() {
          datosCSV = rows;
          error = null;
        });
      } else {
        setState(() {
          error = 'No se seleccionó ningún archivo';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al importar: $e';
      });
    }
  }

  Future<void> subirDatosAFirestore() async {
    if (datosCSV == null || datosCSV!.isEmpty) return;

    final headers = datosCSV!.first;
    final registros = datosCSV!.skip(1);

    int subidos = 0;

    for (var fila in registros) {
      final Map<String, dynamic> map = {};

      for (int i = 0; i < headers.length; i++) {
        map[headers[i].toString()] = fila[i];
      }

      try {
        final book = Book(
          titulo: map['titulo'] ?? '',
          subtitulo: map['subtitulo'],
          autor: map['autor'] ?? '',
          editorial: map['editorial'] ?? '',
          coleccion: map['coleccion'],
          anio: int.tryParse(map['anio'].toString()) ?? 0,
          isbn: map['isbn'],
          edicion: int.tryParse(map['edicion'].toString()) ?? 1,
          estante: int.tryParse(map['estante'].toString()) ?? 0,
          almacen: int.tryParse(map['almacen'].toString()) ?? 0,
          copias: int.tryParse(map['copias'].toString()) ?? 1,
          areaConocimiento: map['areaConocimiento'] ?? 'Sin definir',
          precio: double.tryParse(map['precio'].toString()) ?? 0.0,
          formato: map['formato'] ?? '',
          estado: map['estado'].toString().toLowerCase() == 'true',
          fechaRegistro: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('libros')
            .add(book.toMap());

        subidos++;
      } catch (e) {
        print('Error al subir fila: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$subidos libros subidos exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Importar CSV', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.upload_file),
            label: Text('Seleccionar archivo CSV'),
            onPressed: importarCSV,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: Icon(Icons.cloud_upload),
            label: Text('Subir a Firestore'),
            onPressed: subirDatosAFirestore,
          ),
          const SizedBox(height: 20),
          if (error != null)
            Text(error!, style: TextStyle(color: Colors.red)),
          if (datosCSV != null)
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: datosCSV!.length,
                itemBuilder: (context, index) {
                  final fila = datosCSV![index];
                  return ListTile(
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