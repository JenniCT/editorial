import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book_m.dart';

class BookQrView extends StatelessWidget {
  final Book book;
  final ScreenshotController screenshotController = ScreenshotController();
  

  BookQrView({super.key, required this.book});

  String bookToQrData(Book book) {
    final data = {
      'Título': book.titulo,
      'Autor': book.autor,
      'Editorial': book.editorial,
      'Año': book.anio,
      'ISBN': book.isbn ?? 'Sin ISBN',
      'Área': book.areaConocimiento,
      'Copias': book.copias,
      'Registrado por': book.registradoPor,
    };
    return data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final qrData = bookToQrData(book);

    return Scaffold(
      appBar: AppBar(title: const Text('Código QR del Libro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: screenshotController,
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 250.0,
                gapless: false,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Descargar QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(138, 43, 226, 0.6),
              ),
              onPressed: () async {
                final scaffoldContext = context; // Evita usar context después de await

                final image = await screenshotController.capture();
                if (image == null) return;

                final status = await Permission.storage.request();
                if (!status.isGranted) return;

                final directory = await getApplicationDocumentsDirectory();
                final filePath = '${directory.path}/${book.titulo}_qr.png';
                final file = File(filePath);
                await file.writeAsBytes(image);

                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(content: Text('QR guardado en: $filePath')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}