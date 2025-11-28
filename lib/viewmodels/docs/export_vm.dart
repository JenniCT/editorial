//=========================== IMPORTACIONES PRINCIPALES ===========================//
// ESTAS IMPORTACIONES PERMITEN ACCEDER A FUNCIONALIDADES ESENCIALES PARA GENERAR,
// MANIPULAR Y DESCARGAR ARCHIVOS EXCEL, TANTO EN WEB COMO EN APLICACIONES MÓVILES.
// SE MANTIENE UNA NARRATIVA DE ACCESIBILIDAD Y ADAPTACIÓN MULTIPLATAFORMA.

import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ex;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// IMPORTACIÓN ESPECIAL PARA WEB, PERMITIENDO DESCARGA DIRECTA DESDE EL NAVEGADOR.
// SE USA PARA RESPONDER A LA EXPERIENCIA INMEDIATA DE QUIEN INTERACTÚA EN LÍNEA.
import 'dart:html' as html;

//=========================== DECLARACIÓN DEL VIEWMODEL ===========================//
// ESTE VIEWMODEL CENTRALIZA LA LÓGICA DE EXPORTACIÓN, SOSTENIENDO UNA NARRATIVA
// DE ORDEN, DIGNIDAD Y COHERENCIA INSTITUCIONAL EN TODA LA OPERACIÓN.
class ExportViewModel {

  //=========================== MÉTODO PRINCIPAL DE EXPORTACIÓN ===========================//
  // ESTE MÉTODO CONSTRUYE Y ENTREGA UN ARCHIVO EXCEL COMPLETO, REFLEJANDO
  // LA INFORMACIÓN DE MANERA CLARA, ESTRUCTURADA Y VISIBLEMENTE ARMÓNICA.
  Future<void> exportToExcel({
    required List<Map<String, dynamic>> data,
    required String fileName,
    required BuildContext context,
  }) async {

    try {

      //=========================== VALIDACIÓN DE DATOS ===========================//
      // VERIFICAMOS QUE EXISTA INFORMACIÓN PARA EXPORTAR, CUIDANDO UNA RESPUESTA
      // HUMANA Y DIRECTA ANTE ESCENARIOS VACÍOS.
      if (data.isEmpty) {
        _showSnackBar(context, 'No hay datos para exportar.');
        return;
      }

      //=========================== CREACIÓN DEL DOCUMENTO EXCEL ===========================//
      // SE CREA UNA INSTANCIA DE EXCEL, BASE DESDE DONDE SE CONSTRUYE LA EXPERIENCIA VISUAL.
      final excel = ex.Excel.createExcel();

      const sheetName = 'Libros';

      // INDICAMOS EL INGRESO A LA HOJA PRINCIPAL "LIBROS", QUE SE CREA SI NO EXISTE.
      // ESTA ACCIÓN GARANTIZA UN ESPACIO ORDENADO Y CENTRAL PARA EL CONTENIDO.
      final sheet = excel[sheetName];

      //=========================== LIMPIEZA DE HOJAS INNECESARIAS ===========================//
      // ELIMINAMOS HOJAS AUTOMÁTICAS COMO "SHEET1" PARA MANTENER UNA NARRATIVA LIMPIA.
      // SE PROTEGE LA COHERENCIA VISUAL Y EL FOCO EN LA INFORMACIÓN REAL.
      final otherSheets = excel.sheets.keys.where((k) => k != sheetName).toList();
      for (var name in otherSheets) {
        excel.delete(name);
      }

      //=========================== PREPARACIÓN DE ENCABEZADOS ===========================//
      // EXTREMAMOS CLARIDAD DEFINIENDO LOS ENCABEZADOS DESDE LA PRIMERA FILA DE LOS DATOS.
      final headers = data.first.keys.toList();
      final lastColIndex = headers.length - 1;

      //=========================== ESTILO DE TÍTULO ===========================//
      // SE USA NEGRITA Y CENTRADO PARA TRANSMITIR FUERZA, FORMALIDAD Y PRESENCIA INSTITUCIONAL.
      // EL TÍTULO UNE VISUALMENTE EL DOCUMENTO, GENERANDO UNA IDENTIDAD CLARA.
      final titleStyle = ex.CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: ex.HorizontalAlign.Center,
        verticalAlign: ex.VerticalAlign.Center,
        textWrapping: ex.TextWrapping.WrapText, // AJUSTE DE TEXTO PARA LECTURA AMPLIA.
      );

      // MERGE DEL TÍTULO SOBRE TODA LA PRIMERA FILA PARA CREAR UN ENCABEZADO SÓLIDO Y CENTRALIZADO.
      sheet.merge(
        ex.CellIndex.indexByString("A1"),
        ex.CellIndex.indexByColumnRow(columnIndex: lastColIndex, rowIndex: 0),
      );

      // APLICACIÓN DEL CONTENIDO DE TÍTULO CON SU ESTILO DEFINIDO.
      final titleCell = sheet.cell(ex.CellIndex.indexByString("A1"));
      titleCell.value = ex.TextCellValue("Dirección editorial");
      titleCell.cellStyle = titleStyle;

      // SE AGREGA UNA FILA EN BLANCO PARA CREAR RESPIRO VISUAL ANTES DE LOS ENCABEZADOS.
      sheet.appendRow([]);

      //=========================== ESTILO DE ENCABEZADOS ===========================//
      // LOS ENCABEZADOS USAN NEGRITA Y BORDES COMPLETOS PARA REFORZAR CLARIDAD Y SEPARACIÓN.
      // LOS BORDES DELIMITAN LA INFORMACIÓN Y MEJORAN LA NAVEGACIÓN VISUAL ENTRE COLUMNAS.
      final headerStyle = ex.CellStyle(
        bold: true,
        horizontalAlign: ex.HorizontalAlign.Center,
        verticalAlign: ex.VerticalAlign.Center,
        textWrapping: ex.TextWrapping.WrapText,
        leftBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
        rightBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
        topBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
        bottomBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
      );

      // SE AGREGA LA FILA DE ENCABEZADOS A PARTIR DE LAS CLAVES DEL MAPA.
      final headerValues = headers.map((h) => ex.TextCellValue(h)).toList();
      sheet.appendRow(headerValues);

      // APLICACIÓN DE ESTILO A CADA CELDA DEL ENCABEZADO, REFUERZA SU IDENTIDAD.
      final headerRowIndex = sheet.maxRows - 1;
      for (int c = 0; c < headers.length; c++) {
        final cell = sheet.cell(
          ex.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: headerRowIndex),
        );
        cell.cellStyle = headerStyle;
      }

      //=========================== RENDERIZADO DE FILAS DE DATOS ===========================//
      // SE RELLENA EL CUERPO DE INFORMACIÓN, CUIDANDO LA INTEGRIDAD VISUAL CON BORDES Y AJUSTES.
      for (final row in data) {
        final rowValues = headers
            .map((k) => ex.TextCellValue(row[k]?.toString() ?? ''))
            .toList();

        sheet.appendRow(rowValues);

        final rowIndex = sheet.maxRows - 1;

        // APLICACIÓN DE ESTILO A CADA CELDA DEL CONTENIDO.
        // SE BUSCA UNA PRESENTACIÓN ARMÓNICA Y ESTRUCTURAL QUE GUÍE LA MIRADA.
        for (int c = 0; c < headers.length; c++) {
          final cell = sheet.cell(
            ex.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIndex),
          );

          cell.cellStyle = ex.CellStyle(
            textWrapping: ex.TextWrapping.WrapText,
            leftBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
            rightBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
            topBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
            bottomBorder: ex.Border(borderStyle: ex.BorderStyle.Thin),
          );
        }
      }

      //=========================== AJUSTE AUTOMÁTICO DE ANCHO ===========================//
      // ESTE BLOQUE GARANTIZA QUE LAS COLUMNAS NO QUEDEN NI DEMASIADO ANCHAS
      // NI TAN REDUCIDAS QUE OBSTACULICEN LA LECTURA. SE BUSCA EQUILIBRIO VISUAL.
      for (int col = 0; col < headers.length; col++) {
        int maxLen = headers[col].toString().length;

        // SE CALCULA LA LONGITUD MÁXIMA POR COLUMNA.
        for (var r = 0; r < sheet.maxRows; r++) {
          final cell = sheet.cell(
            ex.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r),
          );
          if (cell.value != null) {
            final len = cell.value.toString().length;
            if (len > maxLen) maxLen = len;
          }
        }

        // SE DEFINE UN ANCHO ARMÓNICO CON UN LÍMITE PARA EVITAR DESBALANCE VISUAL.
        double width = (maxLen + 4).toDouble();
        double maxWidth = 35;

        sheet.setColumnWidth(col, width > maxWidth ? maxWidth : width);
      }

      //=========================== PROCESO FINAL DE EXPORTACIÓN ===========================//
      // EL DOCUMENTO SE CODIFICA Y SE ENTREGA ADAPTÁNDOSE A WEB O DISPOSITIVOS MÓVILES.
      final bytes = excel.encode();
      if (bytes == null) {
        _showSnackBar(context, 'Error al generar el archivo.');
        return;
      }

      //=========================== EXPORTACIÓN EN WEB ===========================//
      // EN PLATAFORMAS WEB SE DESCARGA DIRECTAMENTE EL ARCHIVO,
      // CUIDANDO UNA EXPERIENCIA INMEDIATA Y CLARA.
      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.xlsx')
          ..click();

        html.Url.revokeObjectUrl(url);

        if (!context.mounted) return;
        _showSnackBar(context, 'Archivo descargado correctamente.');
        return;
      }

      //=========================== EXPORTACIÓN EN MÓVIL / ESCRITORIO ===========================//
      // AQUÍ SE GUARDA EL ARCHIVO EN MEMORIA DEL SISTEMA Y SE COMPARTE UTILIZANDO
      // share_plus PARA OFRECER UNA EXPERIENCIA FLUIDA Y HUMANA.
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)], 
          text: 'Exportación de $fileName',
        ),
      );

      if (!context.mounted) return;
      _showSnackBar(context, 'Archivo exportado correctamente.');

    } catch (e, s) {
      //=========================== MANEJO DE ERRORES ===========================//
      // SE OFRECE CONTENCIÓN Y VISIBILIDAD ANTE PROBLEMAS INESPERADOS,
      // CUIDANDO MANTENER UNA COMUNICACIÓN RESPETUOSA Y EMPÁTICA.
      debugPrint('Error al exportar Excel: $e\n$s');
      if (!context.mounted) return;
      _showSnackBar(context, 'Error durante la exportación.');
    }
  }

  //=========================== MÉTODO DE FEEDBACK VISUAL ===========================//
  // ESTE MÉTODO ENTREGA MENSAJES VISUALES DE ESTADO, APORTANDO CLARIDAD Y
  // ACOMPAÑAMIENTO DURANTE LA EXPERIENCIA DE EXPORTACIÓN.
  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1C2532), // COLOR OSCURO PARA PRESENCIA Y SERIEDAD.
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
