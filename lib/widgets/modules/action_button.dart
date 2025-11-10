import 'package:flutter/material.dart';
import 'header_button.dart';

/// Botón moderno con ícono de Cupertino, texto y animación hover con sombra.
class ActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final ActionType type;

  const ActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.type = ActionType.secondary,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.type == ActionType.primary;
    final isDanger = widget.type == ActionType.danger;

    // 🎨 Colores base
    final Color bgColor = isPrimary
        ? const Color(0xFF1C2532)
        : isDanger
            ? const Color(0xFFD9534F)
            : Colors.white;

    final Color textColor = isPrimary || isDanger
        ? Colors.white
        : const Color.fromRGBO(0, 0, 0, 0.85);

    final BoxBorder? border =
        widget.type == ActionType.secondary ? Border.all(color: Colors.black26) : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: border,
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
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