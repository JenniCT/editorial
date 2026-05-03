import 'package:flutter/material.dart';

import '../add/app_text_field.dart';
import '../add/app_section_title.dart';

class IdentificationSection extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController subtituloController;
  final TextEditingController autorController;
  final TextEditingController isbnController;

  const IdentificationSection({
    super.key,
    required this.tituloController,
    required this.subtituloController,
    required this.autorController,
    required this.isbnController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(
          title: 'Identificación',
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'Título',
                hint: 'Ingrese el título del libro',
                controller: tituloController,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AppTextField(
                label: 'Subtítulo',
                hint: 'Subtítulo (opcional)',
                controller: subtituloController,
                required: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        AppTextField(
          label: 'Autor(es)',
          hint: 'Ingrese el nombre del autor',
          controller: autorController,
        ),

        const SizedBox(height: 12),

        AppTextField(
          label: 'ISBN',
          hint: 'Ej. 978-607-561-088-7',
          controller: isbnController,
          required: false,
        ),
      ],
    );
  }
}