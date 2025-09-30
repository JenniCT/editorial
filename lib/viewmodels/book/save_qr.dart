import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';

Future<void> saveQrImage(GlobalKey key, String titulo) async {
  try {
    // Obtener la imagen del RepaintBoundary
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Usar FilePicker.platform.saveFile (API de file_picker)
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar QR',
      fileName: '$titulo.png',
      type: FileType.custom,
      allowedExtensions: ['png'],
    );

    if (path == null) {
      debugPrint('Guardado cancelado por el usuario');
      return;
    }

    // Asegurar que la extensión .png esté incluida
    if (!path.endsWith('.png')) {
      path = '$path.png';
    }

    // Guardar el archivo
    final file = File(path);
    await file.writeAsBytes(pngBytes);

    debugPrint('QR guardado en: $path');
  } catch (e) {
    debugPrint('Error guardando QR: $e');
  }
}