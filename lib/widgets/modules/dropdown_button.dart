import 'package:flutter/material.dart';
import 'header_button.dart';

class StyledDropdownButton extends StatefulWidget {
  final List<HeaderButton> items;

  const StyledDropdownButton({super.key, required this.items});

  @override
  State<StyledDropdownButton> createState() => StyledDropdownButtonState();
}

class StyledDropdownButtonState extends State<StyledDropdownButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // mismo padding que ActionButton
        child: DropdownButtonHideUnderline(
          child: DropdownButton<HeaderButton>(
            isDense: true, // elimina padding extra
            hint: const Text(
              'Más opciones',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(0, 0, 0, 0.85),
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color.fromRGBO(0, 0, 0, 0.85)),
            items: widget.items.map((b) {
              return DropdownMenuItem<HeaderButton>(
                value: b,
                child: Row(
                  children: [
                    Icon(b.icon, size: 18),
                    const SizedBox(width: 8),
                    Text(b.text),
                  ],
                ),
              );
            }).toList(),
            onChanged: (b) {
              if (b != null) b.onPressed();
            },
          ),
        ),
      ),
    );
  }
}
