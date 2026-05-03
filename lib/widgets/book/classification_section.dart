import 'package:flutter/material.dart';

import '../add/app_dropdown_field.dart';
import '../add/app_section_title.dart';

class ClassificationSection extends StatelessWidget {
  final String selectedArea;
  final ValueChanged<String?> onChanged;
  final List<String> areas;

  const ClassificationSection({
    super.key,
    required this.selectedArea,
    required this.onChanged,
    required this.areas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(
          title: 'Clasificación',
        ),

        AppDropdownField(
          label: 'Área de conocimiento',
          value: selectedArea.isEmpty ? null : selectedArea,
          items: areas,
          hint: 'Seleccione el área',
          onChanged: onChanged,
        ),
      ],
    );
  }
}