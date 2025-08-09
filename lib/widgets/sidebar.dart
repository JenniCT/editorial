import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class Sidebar extends StatelessWidget {
  final SidebarXController controller;

  const Sidebar({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      showToggleButton: true,
      animationDuration: const Duration(milliseconds: 300),
      theme: SidebarXTheme(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        hoverColor: Colors.grey[200],
        selectedTextStyle: const TextStyle(color: Colors.blueAccent),
        selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
        iconTheme: IconThemeData(color: Colors.grey[800]),
        textStyle: const TextStyle(fontSize: 12),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(color: Colors.white),
      ),
      items: const [
        SidebarXItem(icon: Icons.dashboard, label: 'Dashboard'),
        SidebarXItem(icon: Icons.book, label: 'Libros'),
        SidebarXItem(icon: Icons.volunteer_activism, label: 'Donaciones'),
        SidebarXItem(icon: Icons.shopping_cart, label: 'Ventas'),
        SidebarXItem(icon: Icons.analytics, label: 'Analisis'),
        SidebarXItem(icon: Icons.settings, label: 'Configuracion'),
        SidebarXItem(icon: Icons.logout, label: 'Log out'),
      ],
    );
  }
}
