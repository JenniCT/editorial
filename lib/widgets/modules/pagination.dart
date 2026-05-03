import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  static const Color _blue       = Color(0xFF052B67);
  static const Color _blueSoft   = Color(0xFFEEF2FB);
  static const Color _border     = Color(0xFFDDE3EE);
  static const Color _textDark   = Color(0xFF1F2937);
  static const Color _textMuted  = Color(0xFFB0BAC9);

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / itemsPerPage).ceil();

    final startItem = totalItems == 0 ? 0 : currentPage * itemsPerPage + 1;
    final endItem   = ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          //=========================== INFO ===========================//
          Text(
            '$startItem - $endItem de $totalItems',
            style: const TextStyle(
              color: _textDark,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          //=========================== CONTROLES ===========================//
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Ir a primera página
                _NavBtn(
                  icon: Icons.first_page_rounded,
                  enabled: currentPage > 0,
                  onTap: () => onPageChanged(0),
                  blue: _blue,
                  muted: _textMuted,
                ),

                const SizedBox(width: 2),

                // Página anterior
                _NavBtn(
                  icon: Icons.chevron_left_rounded,
                  enabled: currentPage > 0,
                  onTap: () => onPageChanged(currentPage - 1),
                  blue: _blue,
                  muted: _textMuted,
                ),

                const SizedBox(width: 4),

                // Números de página
                ..._buildPageNumbers(totalPages),

                const SizedBox(width: 4),

                // Página siguiente
                _NavBtn(
                  icon: Icons.chevron_right_rounded,
                  enabled: currentPage < totalPages - 1,
                  onTap: () => onPageChanged(currentPage + 1),
                  blue: _blue,
                  muted: _textMuted,
                ),

                const SizedBox(width: 2),

                // Ir a última página
                _NavBtn(
                  icon: Icons.last_page_rounded,
                  enabled: currentPage < totalPages - 1,
                  onTap: () => onPageChanged(totalPages - 1),
                  blue: _blue,
                  muted: _textMuted,
                ),

                //=========================== ITEMS POR PÁGINA ===========================//
                if (onItemsPerPageChanged != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: itemsPerPage,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: _textDark,
                        ),
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        items: [10, 25, 50]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('$e / pág'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) onItemsPerPageChanged!(value);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  //=========================== NÚMEROS DE PÁGINA ===========================//
  List<Widget> _buildPageNumbers(int totalPages) {
    final List<Widget> pages = [];
    final int maxVisible = 5;

    int start = (currentPage - 2).clamp(0, (totalPages - maxVisible).clamp(0, totalPages));
    int end   = (start + maxVisible).clamp(0, totalPages);

    if (start > 0) {
      pages.add(_PageItem(index: 0, currentPage: currentPage, onTap: onPageChanged, blue: _blue, blueSoft: _blueSoft, border: _border, textDark: _textDark));
      if (start > 1) {
        pages.add(const _Ellipsis());
      }
    }

    for (int i = start; i < end; i++) {
      pages.add(_PageItem(
        index: i,
        currentPage: currentPage,
        onTap: onPageChanged,
        blue: _blue,
        blueSoft: _blueSoft,
        border: _border,
        textDark: _textDark,
      ));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        pages.add(const _Ellipsis());
      }
      pages.add(_PageItem(index: totalPages - 1, currentPage: currentPage, onTap: onPageChanged, blue: _blue, blueSoft: _blueSoft, border: _border, textDark: _textDark));
    }

    return pages;
  }
}


//=========================== BOTÓN DE NAVEGACIÓN ===========================//
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color blue;
  final Color muted;

  const _NavBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.blue,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled ? blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? Colors.white : muted,
          ),
        ),
      ),
    );
  }
}


//=========================== NÚMERO DE PÁGINA ===========================//
class _PageItem extends StatelessWidget {
  final int index;
  final int currentPage;
  final ValueChanged<int> onTap;
  final Color blue;
  final Color blueSoft;
  final Color border;
  final Color textDark;

  const _PageItem({
    required this.index,
    required this.currentPage,
    required this.onTap,
    required this.blue,
    required this.blueSoft,
    required this.border,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? blue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? blue : border,
                width: 1,
              ),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


//=========================== ELLIPSIS ===========================//
class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 24,
        height: 32,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            '...',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}