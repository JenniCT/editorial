import 'package:flutter/material.dart';

class HoverButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const HoverButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.color.withAlpha((_isHovered ? 0.6 : 0.3) * 255 ~/ 1);
    final blurRadius = _isHovered ? 12.0 : 6.0;
    final offsetY = _isHovered ? 6.0 : 3.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: InkWell(
          onTap: widget.onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.grey[700], size: 20),
              SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}