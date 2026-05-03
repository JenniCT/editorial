import 'package:flutter/material.dart';

import '../add/app_number_field.dart';
import '../add/app_section_title.dart';

class StockSection extends StatelessWidget {
  final TextEditingController copiasController;
  final TextEditingController estanteController;
  final TextEditingController almacenController;

  const StockSection({
    super.key,
    required this.copiasController,
    required this.estanteController,
    required this.almacenController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(
          title: 'Stock',
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppNumberField(
                label: 'Número de copias',
                hint: '0',
                controller: copiasController,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AppNumberField(
                label: 'Estante',
                hint: '0',
                controller: estanteController,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AppNumberField(
                label: 'Almacén',
                hint: '0',
                controller: almacenController,
              ),
            ),
          ],
        ),
      ],
    );
  }
}