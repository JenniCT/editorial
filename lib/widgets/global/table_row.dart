import 'package:flutter/material.dart';

class CustomTableRow extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final List<double>? columnWidths;

  const CustomTableRow({required this.children, this.height = 50, this.columnWidths, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(children.length, (index) {
          return Container(
            width: columnWidths != null && columnWidths!.length > index
                ? columnWidths![index]
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: children[index],
          );
        }),
      ),
    );
  }
}
