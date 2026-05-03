import 'package:flutter/material.dart';
import 'table_hover_row.dart';

class CustomTable extends StatelessWidget {
  final List<Widget> headers;
  final List<List<Widget>> rows;
  final double rowHeight;
  final double? width;
  final List<double>? columnWidths;
  final Widget? topWidget;

  const CustomTable({
    super.key,
    required this.headers,
    required this.rows,
    this.rowHeight = 72,
    this.width,
    this.columnWidths,
    this.topWidget,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = width ?? 1400;

    final calculatedColumnWidths =
        columnWidths ??
        List.generate(
          headers.length,
          (_) => totalWidth / headers.length,
        );

    Widget buildRow(
      List<Widget> children, {
      bool isHeader = false,
    }) {
      return TableHoverRow(
        isHeader: isHeader,
        height: isHeader ? 56 : rowHeight,

        child: Row(
          children: List.generate(
            children.length,
            (index) {
              final isCheckboxColumn = index == 0;
              final isCoverColumn = index == 1;
              final isStockColumn = index == 4;
              final isActionsColumn =
                  index == children.length - 1;

              return Container(
                width: calculatedColumnWidths[index],

                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                alignment:
                    isCheckboxColumn ||
                            isCoverColumn ||
                            isStockColumn ||
                            isActionsColumn
                        ? Alignment.center
                        : Alignment.centerLeft,

                child: DefaultTextStyle(
                  style: TextStyle(
                    color: isHeader
                        ? Colors.white
                        : const Color(0xFF1C2532),
                    fontSize: 14,
                    fontWeight: isHeader
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                  child: children[index],
                ),
              );
            },
          ),
        ),
      );
    }

    Widget buildEmptyRow() {
      return SizedBox(
        height: rowHeight,
        child: const Center(
          child: Text(
            "No hay libros disponibles",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFEAECEF),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (topWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: topWidget!,
                    ),

                  // HEADER
                  buildRow(
                    headers,
                    isHeader: true,
                  ),

                  // FILAS
                  if (rows.isEmpty)
                    buildEmptyRow()
                  else
                    ...rows.map(
                      (columns) => Column(
                        children: [
                          buildRow(columns),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F3F5),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}