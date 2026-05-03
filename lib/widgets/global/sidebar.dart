import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String userName;
  final String userRole;
  final Map<String, bool> permisosModulos;

  const Sidebar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userName,
    required this.userRole,
    required this.permisosModulos,
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // ValueNotifier en lugar de setState → solo el listener
  // (AnimatedContainer) se reconstruye al colapsar/expandir.
  final ValueNotifier<bool> _expanded = ValueNotifier(false);

  static const List<_SidebarItem> _items = [
    _SidebarItem(icon: CupertinoIcons.home,           label: 'Dashboard'),
    _SidebarItem(icon: CupertinoIcons.book,           label: 'Inventario'),
    _SidebarItem(icon: CupertinoIcons.archivebox,     label: 'Acervo'),
    _SidebarItem(icon: CupertinoIcons.cart,           label: 'Ventas'),
    _SidebarItem(icon: CupertinoIcons.heart,          label: 'Donaciones'),
    _SidebarItem(icon: CupertinoIcons.person_2,       label: 'Usuarios'),
    _SidebarItem(icon: CupertinoIcons.square_arrow_right, label: 'Cerrar sesión'),
  ];

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  bool _tieneAcceso(String label) {
    if (label == 'Dashboard' || label == 'Cerrar sesión') return true;
    return widget.permisosModulos[label] ?? false;
  }

  // ─── Contenido compartido (móvil + desktop) ─────────────────
  Widget _sidebarContent(bool expanded) {
    return Column(
      children: [
        // ── Cabecera ──────────────────────────────────────────
        _SidebarHeader(
          expanded: expanded,
          userEmail: widget.userName,
          userRole: widget.userRole,
        ),

        // ── Ítems ─────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            // padding fijo evita recalcular en cada frame
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _items.length,
            itemBuilder: (_, index) {
              final item = _items[index];
              return _SidebarTile(
                item: item,
                index: index,
                isSelected: index == widget.selectedIndex,
                expanded: expanded,
                enabled: _tieneAcceso(item.label),
                onTap: () => widget.onItemSelected(index),
              );
            },
          ),
        ),

        // ── Botón colapsar ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: IconButton(
            onPressed: () => _expanded.value = !_expanded.value,
            icon: Icon(
              expanded ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.white70,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 800;

    // ── Modo móvil: Drawer ────────────────────────────────────
    if (isMobile) {
      return Drawer(
        width: 270,
        backgroundColor: const Color(0xFF1C2532),
        child: _sidebarContent(true),
      );
    }

    // ── Modo desktop: AnimatedContainer aislado ───────────────
    return RepaintBoundary(
      child: ValueListenableBuilder<bool>(
        valueListenable: _expanded,
        builder: (_, expanded, _) => AnimatedContainer(
          clipBehavior: Clip.hardEdge,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: expanded ? 260 : 90,
          decoration: const BoxDecoration(
            color: Color(0xFF1C2532),
            boxShadow: [
              BoxShadow(
                color: Color(0x13000000),
                blurRadius: 10,
              ),
            ],
          ),
          child: _sidebarContent(expanded),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CABECERA — StatelessWidget independiente
//  Al ser const-friendly, Flutter la reutiliza sin reconstruir
//  cuando solo cambia el índice seleccionado.
// ════════════════════════════════════════════════════════════
class _SidebarHeader extends StatelessWidget {
  final bool expanded;
  final String userEmail;
  final String userRole;

  const _SidebarHeader({
    required this.expanded,
    required this.userEmail,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFA9B4C6),
            child: Icon(
              CupertinoIcons.person_solid,
              color: Color(0xFF1C2532),
              size: 30,
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            Text(
              userEmail,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              userRole,
              style: const TextStyle(
                color: Color(0x99FFFFFF),
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0x1AFFFFFF), height: 1),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ÍTEM DE MENÚ — StatefulWidget
//
//  • MouseRegion propio para hover explícito: cambia el fondo
//    del Container directamente, visible en Flutter Web
//  • hoverColor en InkWell eliminado (redundante con lo anterior)
//  • El setState solo reconstruye este widget, no el ListView
//  • Transición suave del fondo con AnimatedContainer
// ════════════════════════════════════════════════════════════
class _SidebarTile extends StatefulWidget {
  final _SidebarItem item;
  final int index;
  final bool isSelected;
  final bool expanded;
  final bool enabled;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.index,
    required this.isSelected,
    required this.expanded,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  // Colores de fondo según estado (seleccionado / hover / normal)
  Color get _bgColor {
    if (widget.isSelected) return const Color(0x250061FF);
    if (_hovered && widget.enabled) return const Color(0x140061FF);
    return Colors.transparent;
  }

  // Color del ícono y texto según estado
  Color get _fgColor {
    if (widget.isSelected) return const Color(0xFF4DC0E8);
    if (_hovered && widget.enabled) return Colors.white;
    return const Color(0xFFC6CEDD);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Tooltip(
        message: widget.expanded ? '' : widget.item.label,
        preferBelow: false,
        verticalOffset: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2D000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.enabled ? widget.onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              height: 48,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // ── Línea lateral ──────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: widget.isSelected ? 3.5 : 0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4DC0E8),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),

                  // ── Padding izquierdo ──────────────────────
                  SizedBox(width: widget.expanded ? 12 : 14),

                  // ── Ícono ──────────────────────────────────
                  Icon(widget.item.icon, size: 22, color: _fgColor),

                  // ── Label (solo expandido) ─────────────────
                  if (widget.expanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _fgColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  MODELO INTERNO
// ════════════════════════════════════════════════════════════
class _SidebarItem {
  final IconData icon;
  final String label;

  const _SidebarItem({required this.icon, required this.label});
}