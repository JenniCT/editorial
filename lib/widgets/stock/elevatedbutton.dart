import 'package:flutter/material.dart';

class ElevatedHoverButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const ElevatedHoverButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.color = Colors.blueAccent,
  });

  @override
  State<ElevatedHoverButton> createState() => _ElevatedHoverButtonState();
}

class _ElevatedHoverButtonState extends State<ElevatedHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.color.withAlpha((_isHovered ? 0.6 : 0.3) * 255 ~/ 1);
    final blurRadius = _isHovered ? 16.0 : 8.0;
    final offsetY = _isHovered ? 8.0 : 4.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: blurRadius,
              offset: Offset(0, offsetY),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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