import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppImageUploader extends StatelessWidget {
  final Uint8List? imageBytes;
  final File? selectedImage;
  final TextEditingController imageUrlController;
  final bool showUrlField;

  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final VoidCallback onToggleUrlField;
  final ValueChanged<String> onUrlChanged;

  const AppImageUploader({
    super.key,
    required this.imageBytes,
    required this.selectedImage,
    required this.imageUrlController,
    required this.showUrlField,
    required this.onPickImage,
    required this.onClearImage,
    required this.onToggleUrlField,
    required this.onUrlChanged,
  });

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      color: const Color(0xFFF8FAFC),
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 40,
          color: Color(0xFFCCCCCC),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = imageBytes != null;
    final urlText = imageUrlController.text.trim();
    final hasUrl = urlText.isNotEmpty && urlText.startsWith('http');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen del libro',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C2532),
          ),
        ),

        const SizedBox(height: 12),

        if (hasFile) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageBytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              TextButton(
                onPressed: onPickImage,
                child: const Text('Cambiar'),
              ),
              TextButton(
                onPressed: onClearImage,
                child: const Text('Quitar'),
              ),
            ],
          ),
        ] else if (hasUrl) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              urlText,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _imagePlaceholder(),
            ),
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: onClearImage,
            child: const Text('Quitar imagen'),
          ),
        ] else ...[
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF052B67).withValues(alpha: 0.25),
                ),
              ),
              child: const Center(
                child: Text(
                  'Haz clic para seleccionar una imagen',
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: onToggleUrlField,
            child: const Text(
              'O ingresar una URL de imagen',
              style: TextStyle(
                color: Color(0xFF052B67),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (showUrlField) ...[
            const SizedBox(height: 8),

            TextFormField(
              controller: imageUrlController,
              decoration: _inputDecoration(
                hint: 'https://ejemplo.com/portada.jpg',
              ),
              onChanged: onUrlChanged,
            ),
          ],
        ],
      ],
    );
  }
}