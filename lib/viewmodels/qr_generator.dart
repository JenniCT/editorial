import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/bookM.dart';

class QRGenerator {
  static const String _baseUrl = 'https://tu-dominio.com/libro/'; // Cambia por tu dominio
  
  /// Genera la URL fija para el QR del libro
  static String generateBookQRUrl(String bookId) {
    return '$_baseUrl$bookId';
  }

  /// Genera el widget QR con el título del libro
  static Widget buildQRWidget(Book book, {double size = 200}) {
    final qrUrl = generateBookQRUrl(book.id ?? book.titulo.hashCode.toString());
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título del libro arriba del QR
        Container(
          width: size,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Text(
            book.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Código QR
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: QrImageView(
            data: qrUrl,
            version: QrVersions.auto,
            size: size - 32,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar y descargar el QR de un libro
class BookQRPage extends StatefulWidget {
  final Book book;
  final VoidCallback? onBack;

  const BookQRPage({
    required this.book,
    this.onBack,
    super.key,
  });

  @override
  State<BookQRPage> createState() => _BookQRPageState();
}

class _BookQRPageState extends State<BookQRPage> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Código QR del Libro',
          style: TextStyle(fontSize: 24, fontFamily: 'Roboto'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR Code Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  key: _qrKey,
                  child: QRGenerator.buildQRWidget(
                    widget.book,
                    size: 300,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Información del libro
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(47, 65, 87, 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'ID del libro: ${widget.book.id ?? widget.book.titulo.hashCode.toString()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'URL: ${QRGenerator.generateBookQRUrl(widget.book.id ?? widget.book.titulo.hashCode.toString())}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Este QR siempre mostrará los datos actualizados del libro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botón de descarga
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadQR,
                  icon: _isDownloading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download, color: Colors.white),
                  label: Text(
                    _isDownloading ? 'Descargando...' : 'Descargar QR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(138, 43, 226, 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadQR() async {
    setState(() => _isDownloading = true);

    try {
      // Capturar el widget como imagen
      RenderRepaintBoundary boundary = 
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Aquí puedes implementar la lógica para guardar la imagen
        // Por ejemplo, usando path_provider y permission_handler
        await _saveImageToGallery(pngBytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR descargado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _saveImageToGallery(Uint8List pngBytes) async {
    // Implementa aquí la lógica para guardar en la galería
    // Necesitarás agregar estas dependencias en pubspec.yaml:
    // - path_provider
    // - permission_handler
    // - gallery_saver (opcional)
    
    // Ejemplo básico (necesitas las dependencias):
    /*
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${widget.book.titulo.replaceAll(RegExp(r'[^\w\s]+'), '')}_QR.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      
      // Para guardar en galería (requiere permisos):
      // await GallerySaver.saveImage(file.path);
      
    } catch (e) {
      throw Exception('Error al guardar imagen: $e');
    }
    */
    
    // Simulación por ahora
    await Future.delayed(const Duration(seconds: 1));
  }
}