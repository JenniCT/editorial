import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerField extends StatelessWidget {
  final File? selectedImage;
  final TextEditingController imageUrlController;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  const ImagePickerField({
    super.key,
    required this.selectedImage,
    required this.imageUrlController,
    required this.onPickImage,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromRGBO(255, 255, 255, 0.15),
            ),
            child: selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(selectedImage!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.camera_alt_outlined, size: 40, color: Color.fromRGBO(47, 65, 87, 1)),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: imageUrlController,
          cursorColor: const Color.fromRGBO(255, 255, 255, 0.7),
          style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
          decoration: InputDecoration(
            labelText: 'URL de imagen (opcional)',
            labelStyle: const TextStyle(color: Color.fromRGBO(255, 254, 254, 0.7)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color.fromRGBO(47, 65, 87, 1), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.05),
          ),
          onChanged: (_) => onClearImage(),
        ),
      ],
    );
  }
}
