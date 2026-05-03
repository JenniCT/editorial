import 'package:flutter/material.dart';

class TableText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final Color color;

  const TableText({
    super.key,
    required this.text,
    this.maxLines = 2,
    this.textAlign = TextAlign.start,
    this.fontWeight = FontWeight.w500,
    this.color = const Color(0xFF1C2532),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: fontWeight,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}