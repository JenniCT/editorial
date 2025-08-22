import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/bookM.dart';

class QRBookWidget extends StatefulWidget {
  final Book book;

  const QRBookWidget({super.key, required this.book});

  @override
  State<QRBookWidget> createState() => _QRBookWidgetState();
}

class _QRBookWidgetState extends State<QRBookWidget> {
  final GlobalKey _qrKey = GlobalKey();
  
  Future<void> _downloadQR() async {
    try {
      // Espera a que termine el frame para asegurarte de que el widget se pintó
      await WidgetsBinding.instance.endOfFrame;

      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;


      if (boundary == null) {
        debugPrint("⚠️ No se pudo obtener el RenderRepaintBoundary");
        return;
      }

      // Convierte a imagen con buena resolución
      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Guardar en un archivo temporal
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${widget.book.titulo}_QR.png');
      await file.writeAsBytes(pngBytes);

      // Compartir
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "QR de ${widget.book.titulo}",
      );
    } catch (e) {
      debugPrint("❌ Error al guardar/compartir QR: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final idLibro = widget.book.id ?? "sin_id";

    return Column(
      children: [
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.book.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                QrImageView(
                  data: idLibro, // 🔑 SOLO GUARDA EL ID FIJO
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _downloadQR,
          icon: const Icon(Icons.download),
          label: const Text("Descargar QR"),
        ),
      ],
    );
  }
}
