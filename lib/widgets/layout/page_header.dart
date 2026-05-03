import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget? bottom;
  final double spacing;

  const PageHeader({
    super.key,
    required this.title,
    required this.actions,
    this.bottom,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TÍTULO
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Color(0xFF1C2532),
          ),
        ),

        const SizedBox(height: 18),

        // BOTONES A LA DERECHA
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.end,
                  children: actions,
                ),
              ),
            ),
          ],
        ),

        if (bottom != null) ...[
          SizedBox(height: spacing),
          bottom!,
        ],
      ],
    );
  }
}