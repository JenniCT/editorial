import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;

import '../../../models/book_m.dart';

Future<void> saveBookQrPdf({
  required GlobalKey qrKey,
  required Book book,
}) async {
  try {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    // ignore: use_build_context_synchronously
    final boundary = qrKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      debugPrint('ERROR: boundary es null');
      return;
    }

    final image = await boundary.toImage(
      pixelRatio: 3.0,
    );

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      debugPrint('ERROR: byteData es null');
      return;
    }

    final Uint8List qrBytes =
        byteData.buffer.asUint8List();

    final pdf = pw.Document();
    final qrImage = pw.MemoryImage(qrBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),

        build: (context) => [
          _buildHeader(),

          pw.SizedBox(height: 10),

          pw.Divider(
            thickness: 1,
            color: PdfColors.blue900,
          ),

          pw.SizedBox(height: 14),

          // =====================================
          // BLOQUE SUPERIOR
          // =====================================
          pw.Row(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              // PORTADA
              pw.Container(
                width: 130,
                height: 190,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                  ),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'PORTADA',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),

              pw.SizedBox(width: 18),

              // INFO PRINCIPAL
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      book.titulo,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight:
                            pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    _pdfRow(
                      'Autor',
                      book.autor,
                    ),
                    _pdfRow(
                      'Editorial',
                      book.editorial,
                    ),
                    _pdfRow(
                      'ISBN',
                      book.isbn ?? '—',
                    ),
                    _pdfRow(
                      'Categoría',
                      book.areaConocimiento,
                    ),
                    _pdfRow(
                      'Código interno',
                      book.id ?? '—',
                    ),
                    _pdfRow(
                      'Fecha de registro',
                      _formatDate(
                        book.fechaRegistro,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(width: 16),

              // QR
              pw.Container(
                width: 190,
                padding:
                    const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                  ),
                  borderRadius:
                      pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'CÓDIGO QR DEL LIBRO',
                      textAlign:
                          pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight:
                            pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    pw.Image(
                      qrImage,
                      width: 145,
                      height: 145,
                    ),

                    pw.SizedBox(height: 8),

                    pw.Text(
                      'Escanea para ver los datos del libro',
                      textAlign:
                          pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 18),

          // =====================================
          // SECCIONES VERTICALES
          // =====================================

          pw.Row( crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _sectionBox(
                  'INFORMACIÓN GENERAL',
                  [
                    {
                      'label': 'Título',
                      'value': book.titulo,
                    },
                    {
                      'label': 'Subtítulo',
                      'value': book.subtitulo ?? 'N/A',
                    },
                    {
                      'label': 'Autor',
                      'value': book.autor,
                    },
                    {
                      'label': 'Editorial',
                      'value': book.editorial,
                    },
                    {
                      'label': 'Colección',
                      'value': book.coleccion ?? 'N/A',
                    },
                    {
                      'label': 'Año',
                      'value': book.anio.toString(),
                    },
                  ],
                ),
              ),

              pw.SizedBox(width: 12),

              pw.Expanded(
                child: pw.Column(
                  children: [
                    _sectionBox(
                      'CLASIFICACIÓN',
                      [
                        {
                          'label': 'Área',
                          'value': book.areaConocimiento,
                        },
                        {
                          'label': 'ISBN',
                          'value': book.isbn ?? 'N/A',
                        },
                        {
                          'label': 'Estado',
                          'value': book.estado
                              ? 'Exhibido'
                              : 'No exhibido',
                        },
                      ],
                    ),

                    _sectionBox(
                      'INVENTARIO',
                      [
                        {
                          'label': 'Stock total',
                          'value': book.copias.toString(),
                        },
                        {
                          'label': 'En estante',
                          'value': book.estante.toString(),
                        },
                        {
                          'label': 'En almacén',
                          'value': book.almacen.toString(),
                        },
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(width: 12),

              pw.Expanded(
                child: _sectionBox(
                  'CONTROL Y REGISTRO',
                  [
                    {
                      'label': 'Registrado por',
                      'value': book.registradoPor,
                    },
                    {
                      'label': 'Fecha',
                      'value': _formatDate(
                        book.fechaRegistro,
                      ),
                    },
                    {
                      'label': 'Última modificación',
                      'value':
                          book.fechaModificacion != null
                              ? _formatDate(
                                  book.fechaModificacion!,
                                )
                              : 'N/A',
                    },
                  ],
                ),
              ),
            ],
          ),
        ],

        footer: (context) {
          return pw.Container(
            margin:
                const pw.EdgeInsets.only(
              top: 10,
            ),
            padding:
                const pw.EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue900,
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment
                      .spaceBetween,
              children: [
                pw.Text(
                  'Sistema INKVENTORY - UNACH',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Página ${context.pageNumber} de ${context.pagesCount}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final safeTitle = book.titulo.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );

    final blob = web.Blob(
      [pdfBytes.toJS].toJS,
      web.BlobPropertyBag(
        type: 'application/pdf',
      ),
    );

    final url =
        web.URL.createObjectURL(blob);

    web.HTMLAnchorElement()
      ..href = url
      ..download =
          '$safeTitle.pdf'
      ..click();

    web.URL.revokeObjectURL(url);

    debugPrint(
      'PDF descargado: $safeTitle.pdf',
    );
  } catch (e, stack) {
    debugPrint('ERROR PDF: $e');
    debugPrint(stack.toString());
  }
}

pw.Widget _buildHeader() {
  return pw.Row(
    mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INKVENTORY',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight:
                  pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.Text(
            'UNACH',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight:
                  pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
      pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.end,
        children: [
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue900,
              borderRadius:
                  pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'CATÁLOGO DE LIBROS',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'REPORTE DE EJEMPLAR',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _pdfRow(
  String label,
  String value,
) {
  return pw.Padding(
    padding:
        const pw.EdgeInsets.only(
      bottom: 6,
    ),
    child: pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 50,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            softWrap: true,
            style:
                const pw.TextStyle(
              fontSize: 8.5,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _sectionBox(
  String title,
  List<Map<String, String>> items,
) {
  return pw.Container(
    width: double.infinity,
    margin:
        const pw.EdgeInsets.only( bottom: 14,),
    padding:  const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      border: pw.Border.all(
        color: PdfColors.grey300,
        width: 0.7,
      ),
      borderRadius:
          pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight:
                    pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 12),

        ...items.map(
          (item) => pw.Padding(
            padding:
                const pw.EdgeInsets.only(
              bottom: 8,
            ),
            child: pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 50,
                  child: pw.Text(
                    '${item['label']}:',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    item['value'] == null ||
                            item['value']!
                                .trim()
                                .isEmpty
                        ? '—'
                        : item['value']!,
                    softWrap: true,
                    style:
                        const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(
  DateTime date,
) {
  return
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}