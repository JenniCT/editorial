import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_m.dart';

class ImportadorCSVViewModel {
  List<List<dynamic>>? datosCSV;
  String? error;
  bool loading = false;
  bool cancelarImportacion = false;

  final Map<String, String> _mapaEncabezados = {
    'Portada': 'imagenUrl',
    'Título': 'titulo',
    'Subtítulo': 'subtitulo',
    'Autor': 'autor',
    'Editorial': 'editorial',
    'Colección': 'coleccion',
    'Año': 'anio',
    'ISBN': 'isbn',
    'Edición': 'edicion',
    'Copias': 'copias',
    'Precio': 'precio',
    'Estante': 'estante',
    'Almacén': 'almacen',
    'Área de conocimiento': 'areaConocimiento',
  };

  String _decodeBytes(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  String _detectDelimiter(String firstLine) {
    final countComma = firstLine.split(',').length;
    final countSemi = firstLine.split(';').length;
    return (countSemi > countComma) ? ';' : ',';
  }

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

      final contenido = _decodeBytes(bytes);
      final firstLine = contenido.split(RegExp(r'\r?\n')).firstWhere(
            (line) => line.trim().isNotEmpty,
            orElse: () => '',
          );
      final delimiter = firstLine.isNotEmpty ? _detectDelimiter(firstLine) : ',';

      final converter = CsvToListConverter(
        eol: '\n',
        fieldDelimiter: delimiter,
        shouldParseNumbers: false,
      );

    
      final csv = converter.convert(contenido);

      final filasNoVacias = csv.where((fila) {
        return fila.any((celda) {
          final s = celda?.toString().trim() ?? '';
          return s.isNotEmpty;
        });
      }).toList();

      if (filasNoVacias.isEmpty) {
        datosCSV = null;
        error = 'El CSV no contiene filas con datos.';
        return;
      }

      datosCSV = filasNoVacias;
      error = null;
    } catch (e) {
      error = 'Error al leer el archivo: $e';
      datosCSV = null;
    }
  }
  

  Future<void> subirDatosAFirestore(BuildContext context) async {
    if (datosCSV == null || datosCSV!.length < 2) {
      error =
          '⚠️ No hay datos para subir (asegúrate de incluir encabezados y al menos una fila).';
      return;
    }

    loading = true;
    error = null;

    try {
      final encabezadosOriginales =
          datosCSV!.first.map((e) => e?.toString() ?? '').toList();
      final filas = datosCSV!.skip(1);

      final email = FirebaseAuth.instance.currentUser?.email ?? 'desconocido';
      int subidos = 0;

      for (var fila in filas) {
        if (cancelarImportacion) {
            error = 'Importación detenida por el usuario.';
            if(context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Importación detenida')),
            );
            }
            break;
        }
        try {
          final allEmpty =
              fila.every((celda) => (celda?.toString().trim() ?? '').isEmpty);
          if (allEmpty) {
            continue;
          }

          final mapa = <String, dynamic>{};
          for (int i = 0; i < encabezadosOriginales.length; i++) {
            final encabezadoOriginal = encabezadosOriginales[i].trim();
            final mapped =
                _mapaEncabezados[encabezadoOriginal] ?? encabezadoOriginal;

            dynamic value;
            if (i < fila.length) {
              value = fila[i];
            } else {
              value = null;
            }

            mapa[mapped] = value;
          }

          final areaRaw = mapa['areaConocimiento']?.toString().trim();
          final copias = int.tryParse(mapa['copias']?.toString() ?? '') ?? 1;

          final book = Book(
            imagenUrl: limpiarUrl(mapa['imagenUrl']),
            titulo: mapa['titulo']?.toString() ?? '',
            subtitulo: (mapa['subtitulo']?.toString().isNotEmpty == true)
                ? mapa['subtitulo']?.toString()
                : null,
            autor: mapa['autor']?.toString() ?? '',
            editorial: mapa['editorial']?.toString() ?? '',
            coleccion: (mapa['coleccion']?.toString().isNotEmpty ?? false)
                ? mapa['coleccion']?.toString()
                : null,
            anio: int.tryParse(mapa['anio']?.toString() ?? '') ?? 0,
            isbn: (mapa['isbn']?.toString().isNotEmpty ?? false)
                ? mapa['isbn']?.toString()
                : null,
            edicion: int.tryParse(mapa['edicion']?.toString() ?? '') ?? 1,
            copias: copias,
            estante: int.tryParse(mapa['estante']?.toString() ?? '') ?? 0,
            almacen: int.tryParse(mapa['almacen']?.toString() ?? '') ?? 0,
            precio: double.tryParse(mapa['precio']?.toString() ?? '') ?? 0.0,
            areaConocimiento:
                areaRaw?.isNotEmpty == true ? areaRaw! : 'Sin definir',
            estado: copias > 2,
            fechaRegistro: DateTime.now(),
            registradoPor: email,
          );

          final coll = FirebaseFirestore.instance.collection('books');
          final docRef = await coll.add(book.toMap());
          await docRef.update({'idBook': docRef.id});

          subidos++;
        } catch (_) {}
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$subidos libros subidos exitosamente')),
        );
      }
    } catch (e) {
      error = 'Error al procesar los datos: $e';
    } finally {
      loading = false;
    }
  }
}
