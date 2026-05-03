import 'package:flutter/material.dart';

class TableHoverRow extends StatefulWidget {
  final Widget child;
  final bool isHeader;
  final VoidCallback? onTap;
  final double height;

  const TableHoverRow({
    super.key,
    required this.child,
    this.isHeader = false,
    this.onTap,
    required this.height,
  });

  @override
  State<TableHoverRow> createState() =>
      _TableHoverRowState();
}

class _TableHoverRowState
    extends State<TableHoverRow> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: !widget.isHeader
          ? SystemMouseCursors.click
          : MouseCursor.defer,

      onEnter: (_) {
        if (!widget.isHeader) {
          setState(() {
            isHovered = true;
          });
        }
      },

      onExit: (_) {
        if (!widget.isHeader) {
          setState(() {
            isHovered = false;
          });
        }
      },

      child: GestureDetector(
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),

          height: widget.height,

          decoration: BoxDecoration(
            color: widget.isHeader
                ? const Color(0xFF052B67)
                : isHovered
                    ? const Color(0xFFF5F9FF)
                    : Colors.white,
          ),

          child: widget.child,
        ),
      ),
    );
  }
}