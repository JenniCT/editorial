import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/book_m.dart'; 
import '../../viewmodels/book/save_qr.dart';

final GlobalKey qrKey = GlobalKey();

void showBookQrDialog(BuildContext context, Book book) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: qrKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: QrImageView(
                      data: book.bookToQrData(book),
                      version: QrVersions.auto,
                      foregroundColor: const Color.fromRGBO(47, 65, 87, 1),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Escanea para ver los datos del libro',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        // Dentro del AlertDialog
        TextButton(
          child: const Text('Guardar'),
          onPressed: () async {
            await saveQrImage(qrKey, book.titulo); 
            Navigator.pop(context);
          },
),
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
