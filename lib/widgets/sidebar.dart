import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final String selected;
  final Function(String) onItemSelected;

  const Sidebar({
    required this.selected,
    required this.onItemSelected,
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<_SidebarItemData> items = [
    _SidebarItemData('Dashboard', Icons.dashboard),
    _SidebarItemData('Libros', Icons.book),
    _SidebarItemData('Donaciones', Icons.volunteer_activism),
    _SidebarItemData('Ventas', Icons.shopping_cart),
    _SidebarItemData('Analisis', Icons.analytics),
    _SidebarItemData('Configuracion', Icons.settings),
  ];

  double getTopOffset(String label) {
    final index = items.indexWhere((item) => item.label == label);
    return 24.0 + index * 72.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.grey.shade100,
      child: Stack(
        children: [
          
          // Íconos
          Column(
            children: [
              
              const SizedBox(height: 24),
              ...items.map((item) {
                final isSelected = widget.selected == item.label;
                return _SidebarItem(
                  icon: item.icon,
                  label: item.label,
                  selected: isSelected,
                  onTap: () => widget.onItemSelected(item.label),
                );
              }).toList(),
              const Spacer(),
              const Divider(),
              _SidebarItem(
                icon: Icons.logout,
                label: 'Log out',
                selected: false,
                onTap: () => widget.onItemSelected('Log out'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarItemData {
  final String label;
  final IconData icon;

  const _SidebarItemData(this.label, this.icon);
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 72,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.selected ? Colors.blueAccent : Colors.grey[700],
              ),
              if (isHovered || widget.selected)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.selected ? Colors.blueAccent : Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}