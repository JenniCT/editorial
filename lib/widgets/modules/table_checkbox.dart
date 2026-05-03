import 'package:flutter/material.dart';

class TableCheckbox extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final bool enabled;

  const TableCheckbox({
    super.key,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),

          child: Center(
            child: Icon(
              value
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank_outlined,

              size: 24,

              color: !enabled
                  ? Colors.grey
                  : value
                      ? const Color(0xFF1C2532)
                      : const Color(0xFF4DC0E8),
            ),
          ),
        ),
      ),
    );
  }
}