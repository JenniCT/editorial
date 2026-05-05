import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/book_m.dart';
import '../qr/save_qr.dart';

final GlobalKey qrKey = GlobalKey();

void showBookQrDialog(BuildContext context, Book book) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: Container(
          width: 430,
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =========================================
              // TÍTULO + CERRAR
              // =========================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      book.titulo,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF052B67),
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =========================================
              // QR VISUAL (SOLO PREVIEW)
              // =========================================
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: QrImageView(
                      data: book.bookToQrData(book),
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Color(0xFF052B67),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Escanea para ver los datos completos del libro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // =========================================
              // BOTÓN ÚNICO → GENERAR PDF
              // =========================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    CupertinoIcons.arrow_down_to_line,
                    size: 18,
                  ),
                  label: const Text(
                    'Descargar PDF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF052B67),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await saveBookQrPdf(
                      qrKey: qrKey,
                      book: book,
                    );

                    if (!dialogContext.mounted) return;

                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}