import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportViewModel {
  /// Abre el selector de archivos y procesa el Excel.
  /// Retorna una lista de mapas donde cada mapa es una fila del archivo.
  Future<List<Map<String, dynamic>>?> pickAndParseExcel(BuildContext context) async {
    try {
      // 1. Seleccionar el archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        withData: true, // Importante para Web y lectura inmediata
      );

      if (result == null || result.files.isEmpty) return null;

      Uint8List? bytes = result.files.first.bytes;
      if (bytes == null) return null;

      // 2. Decodificar el Excel
      var excel = Excel.decodeBytes(bytes);
      List<Map<String, dynamic>> importedData = [];

      // 3. Iterar sobre las hojas (usualmente la primera)
      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;
        if (rows.isEmpty) continue;

        // Extraer encabezados de la fila 2 (asumiendo que la fila 1 es el título "Dirección Editorial")
        // O de la fila 0 si es un archivo plano. 
        // Para tu formato de exportación, los headers están en la fila 3 (índice 2).
        int headerRowIndex = _findHeaderRow(rows);
        var headers = rows[headerRowIndex].map((cell) => cell?.value.toString() ?? "").toList();

        // Procesar datos después de los encabezados
        for (int i = headerRowIndex + 1; i < rows.length; i++) {
          var row = rows[i];
          Map<String, dynamic> rowData = {};
          for (int j = 0; j < headers.length; j++) {
            if (j < row.length) {
              rowData[headers[j]] = row[j]?.value;
            }
          }
          if (rowData.values.any((v) => v != null)) {
            importedData.add(rowData);
          }
        }
        break; // Solo procesamos la primera hoja con datos
      }

      return importedData;
    } catch (e) {
      debugPrint("Error al importar: $e");
      return null;
    }
  }

  /// Busca la fila que contiene los encabezados reales (Nombre, Correo, etc.)
  int _findHeaderRow(List<List<Data?>> rows) {
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].any((cell) => cell?.value.toString().toLowerCase().contains('nombre') ?? false)) {
        return i;
      }
    }
    return 0;
  }
}