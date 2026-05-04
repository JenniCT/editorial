import 'package:flutter/material.dart';

class PanelSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool showDividerAfter;

  const PanelSection({
    required this.title,
    required this.children,
    this.showDividerAfter = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C2532))),
        const SizedBox(height: 12),
        ...children,
        if (showDividerAfter)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFEEEEEE), height: 1),
          ),
      ],
    );
  }
}