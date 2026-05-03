import 'package:flutter/material.dart';

import '../add/app_text_field.dart';
import '../add/app_number_field.dart';
import '../add/app_section_title.dart';

class PublicationSection extends StatelessWidget {
  final TextEditingController editorialController;
  final TextEditingController coleccionController;
  final TextEditingController anioController;
  final TextEditingController edicionController;

  const PublicationSection({
    super.key,
    required this.editorialController,
    required this.coleccionController,
    required this.anioController,
    required this.edicionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(
          title: 'Publicación',
        ),

        AppTextField(
          label: 'Editorial',
          hint: 'Ej. Dirección Editorial',
          controller: editorialController,
        ),

        const SizedBox(height: 12),

        AppTextField(
          label: 'Colección',
          hint: 'Nombre de la colección',
          controller: coleccionController,
          required: false,
        ),

        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppNumberField(
                label: 'Año',
                hint: 'Ej. 2023',
                controller: anioController,
                maxLength: 4,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AppNumberField(
                label: 'Edición',
                hint: 'Ej. 1',
                controller: edicionController,
                required: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}