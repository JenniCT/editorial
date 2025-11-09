import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String userEmail;
  final String userRole;
  final Map<String, bool> permisosModulos;

  const Sidebar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userEmail,
    required this.userRole,
    required this.permisosModulos,
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = true;
  int _hoveredIndex = -1;

  void toggleSidebar() {
    setState(() => isExpanded = !isExpanded);
  }

  bool _tieneAcceso(String label) {
    if (label == 'Dashboard' || label == 'Cerrar sesión') return true;
    return widget.permisosModulos[label] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isExpanded ? 260.0 : 90.0;

    final menuItems = [
      _SidebarItem(icon: CupertinoIcons.home, label: 'Dashboard'),
      _SidebarItem(icon: CupertinoIcons.book, label: 'Inventario'),
      _SidebarItem(icon: CupertinoIcons.archivebox, label: 'Acervo'),
      _SidebarItem(icon: CupertinoIcons.cart, label: 'Ventas'),
      _SidebarItem(icon: CupertinoIcons.heart, label: 'Donaciones'),
      _SidebarItem(icon: CupertinoIcons.person_2, label: 'Usuarios'),
      _SidebarItem(icon: CupertinoIcons.square_arrow_right, label: 'Cerrar sesión'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF1C2532),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // --- CABECERA CON ICONO, CORREO Y ROL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFA9B4C6),
                  child: const Icon(CupertinoIcons.person_solid,
                      color: Color(0xFF1C2532), size: 30),
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userRole,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.6),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                  ),
                ],
              ],
            ),
          ),

          // --- LISTA DE ITEMS CON LÍNEA EXTERNA
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: isExpanded ? 0 : 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = index == widget.selectedIndex;
                final tieneAcceso = _tieneAcceso(item.label);

                final Color bgColor = (isSelected)
                    ? const Color.fromRGBO(0, 97, 255, 0.15)
                    : (_hoveredIndex == index
                        ? const Color.fromRGBO(0, 97, 255, 0.10)
                        : Colors.transparent);

                return Tooltip(
                  message: tieneAcceso ? item.label : 'Sin permisos para ${item.label}',
                  child: MouseRegion(
                    cursor: tieneAcceso
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = -1),
                    child: GestureDetector(
                      onTap: tieneAcceso ? () => widget.onItemSelected(index) : null,
                      child: Stack(
                        children: [
                          // --- LÍNEA CELESTE EXTERNA
                          if (isSelected)
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 3.5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4DC0E8),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),

                          // --- CONTENEDOR DEL ITEM
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            padding: EdgeInsets.symmetric(
                              horizontal: isExpanded ? 12 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Espaciado entre línea e ícono cuando colapsado
                                if (!isExpanded)
                                  const SizedBox(width: 8),

                                // Ícono centrado o alineado
                                Expanded(
                                  flex: isExpanded ? 0 : 1,
                                  child: Align(
                                    alignment: isExpanded
                                        ? Alignment.centerLeft
                                        : Alignment.center,
                                    child: Icon(
                                      item.icon,
                                      size: 22,
                                      color: isSelected
                                          ? const Color(0xFF4DC0E8)
                                          : const Color(0xFFC6CEDD),
                                    ),
                                  ),
                                ),

                                // Texto visible solo expandido
                                if (isExpanded) const SizedBox(width: 12),
                                if (isExpanded)
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF4DC0E8)
                                            : const Color(0xFFC6CEDD),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- DIVISOR INFERIOR
          Container(
            height: 1,
            color: const Color.fromRGBO(255, 255, 255, 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          // --- BOTÓN DE COLAPSAR
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              icon: Icon(
                isExpanded ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.white70,
                size: 25,
              ),
              onPressed: toggleSidebar,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}
