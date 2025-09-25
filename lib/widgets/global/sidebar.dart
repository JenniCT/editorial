import 'dart:ui';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String userEmail;
  final String userRole;

  const Sidebar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userEmail,
    required this.userRole,
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = false;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _SidebarItem(icon: Icons.dashboard, label: 'Dashboard'),
      _SidebarItem(icon: Icons.book_rounded, label: 'Libros'),
      _SidebarItem(icon: Icons.archive_rounded, label: 'Acervo'),
      _SidebarItem(icon: Icons.shopping_cart, label: 'Ventas'),
      _SidebarItem(icon: Icons.people_alt_rounded, label: 'Usuarios'),
      _SidebarItem(icon: Icons.settings, label: 'Configuración'),
      _SidebarItem(icon: Icons.logout, label: 'Cerrar sesión'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 220 : 72,
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(19, 38, 87, 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color.fromRGBO(47, 65, 87, 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color.fromRGBO(255, 255, 255, 0.9),
                  child: Icon(
                    Icons.person,
                    color: const Color.fromRGBO(47, 65, 87, 0.7),
                    size: 30,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Tooltip(
                      message: widget.userEmail,
                      child: Text(
                        widget.userEmail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Tooltip(
                      message: widget.userRole,
                      child: Text(
                        widget.userRole,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white24, thickness: 0.8),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'MENU',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = index == widget.selectedIndex;

                      return GestureDetector(
                        onTap: () => widget.onItemSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isExpanded ? 12 : 0,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromRGBO(255, 255, 255, 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: isExpanded
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              if (isExpanded) const SizedBox(width: 12),
                              if (isExpanded)
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                    icon: Icon(
                      isExpanded ? Icons.chevron_left : Icons.chevron_right,
                      color: Colors.white70,
                    ),
                    onPressed: toggleSidebar,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;

  const _SidebarItem({required this.icon, required this.label});
}
