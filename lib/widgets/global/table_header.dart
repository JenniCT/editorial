import 'package:flutter/material.dart';

class CustomTableHeader extends StatelessWidget {
  final List<String> headers;
  final List<double>? columnWidths;
  final TextStyle style;

  const CustomTableHeader({
    required this.headers,
    this.columnWidths,
    this.style = const TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(headers.length, (index) {
        return Container(
          width: columnWidths != null && columnWidths!.length > index
              ? columnWidths![index]
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(headers[index], style: style),
        );
      }),
    );
  }
}

