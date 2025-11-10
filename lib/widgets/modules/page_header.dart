import 'package:flutter/material.dart';
import 'dropdown_button.dart';
import 'action_button.dart';
import 'header_button.dart';

class PageHeader extends StatefulWidget {
  final String title;
  final List<HeaderButton> buttons;
  final Widget? bottom;
  final double spacing;

  const PageHeader({
    super.key,
    required this.title,
    required this.buttons,
    this.bottom,
    this.spacing = 20,
  });

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  double _lastWidth = 0;
  int _menuKeyCounter = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_lastWidth < 1024 && screenWidth >= 1024) {
      _menuKeyCounter++;
    }
    _lastWidth = screenWidth;

    final primaryButtons = widget.buttons.where((b) => b.type == ActionType.primary).toList();
    final secondaryButtons = widget.buttons.where((b) => b.type != ActionType.primary).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título arriba
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Color(0xFF1C2532),
          ),
        ),

        const SizedBox(height: 12),

        // ✅ Wrap para evitar desbordes y saltos
        LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (screenWidth >= 1024) ...[
                    // ✅ Desktop: todos los botones
                    ...widget.buttons.map(
                      (btn) => ActionButton(
                        icon: btn.icon,
                        text: btn.text,
                        onPressed: btn.onPressed,
                        type: btn.type,
                      ),
                    ),
                  ],

                  if (screenWidth < 1024) ...[
                    // ✅ Móvil/Tablet: solo primarios
                    ...primaryButtons.map(
                      (btn) => ActionButton(
                        icon: btn.icon,
                        text: btn.text,
                        onPressed: btn.onPressed,
                        type: btn.type,
                      ),
                    ),

                    // ✅ Dropdown para secundarios
                    if (secondaryButtons.isNotEmpty)
                      StyledDropdownButton(
                        key: ValueKey(_menuKeyCounter),
                        items: secondaryButtons,
                      ),
                  ],
                ],
              ),
            );
          },
        ),

        if (widget.bottom != null) ...[
          SizedBox(height: widget.spacing),
          widget.bottom!,
        ],
      ],
    );
  }
}
