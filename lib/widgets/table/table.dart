import 'package:flutter/material.dart';
import 'table_header.dart';
import 'table_row.dart';
import 'dart:ui';

class CustomTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final double rowHeight;
  final double width;
  final List<double>? columnWidths;

  const CustomTable({
    required this.headers,
    required this.rows,
    this.rowHeight = 50,
    this.width = 1460,
    this.columnWidths,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(47, 65, 87, 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromRGBO(47, 65, 87, 0.3)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    CustomTableHeader(headers: headers, columnWidths: columnWidths),
                    const Divider(color: Colors.white54),
                    ...rows
                        .map(
                          (columns) => Column(
                            children: [
                              CustomTableRow(
                                children: columns,
                                height: rowHeight,
                                columnWidths: columnWidths,
                              ),
                              const Divider(color: Colors.white30),
                            ],
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
