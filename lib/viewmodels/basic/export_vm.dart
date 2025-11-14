import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// 🕸️ Import especial solo para Web (descarga directa)
import 'dart:html' as html;

class ExportViewModel {
  /// Exporta datos a Excel (compatible con Web y Móvil)
  Future<void> exportToExcel({
    required List<Map<String, dynamic>> data,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      if (data.isEmpty) {
        _showSnackBar(context, 'No hay datos para exportar.');
        return;
      }

      // Crear archivo Excel
      final excel = Excel.createExcel();
      final sheet = excel['Hoja1'];

      // Encabezados
      final headers = data.first.keys.toList();
      sheet.appendRow(headers);

      // Filas
      for (final row in data) {
        sheet.appendRow(headers.map((key) => row[key]?.toString() ?? '').toList());
      }

      final bytes = excel.encode();
      if (bytes == null) {
        _showSnackBar(context, 'Error al generar el archivo.');
        return;
      }

      //===================== 🌐 WEB =====================//
      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);

        _showSnackBar(context, 'Archivo descargado correctamente.');
        return;
      }

      //===================== 📱 MÓVIL / ESCRITORIO =====================//
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Exportación de $fileName');
      _showSnackBar(context, 'Archivo exportado correctamente.');

    } catch (e) {
      debugPrint('Error al exportar: $e');
      _showSnackBar(context, 'Error durante la exportación.');
    }
  }

  // Mensaje SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1C2532),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
