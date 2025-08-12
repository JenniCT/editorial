import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class Sidebar extends StatelessWidget {
  final SidebarXController controller;

  const Sidebar({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
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
            child: SidebarX(
              controller: controller,
              showToggleButton: true,
              animationDuration: const Duration(milliseconds: 300),
              headerBuilder: (context, extended) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Inkventory',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: extended ? 20 : 0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                );
              },
              theme: SidebarXTheme(
                decoration: const BoxDecoration(),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                selectedIconTheme: const IconThemeData(color: Colors.white),
                iconTheme: const IconThemeData(color: Colors.white70),
                textStyle: const TextStyle(fontSize: 13, color: Colors.white),
              ),
              
              extendedTheme: SidebarXTheme(
                width: 220,
                decoration: const BoxDecoration(),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textStyle: const TextStyle(fontSize: 14, color: Colors.white),
                itemTextPadding: const EdgeInsets.symmetric(horizontal: 16),
                itemMargin: const EdgeInsets.symmetric(vertical: 8),
                itemDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.transparent,
                ),
              ),
              items: const [
                SidebarXItem(icon: Icons.dashboard, label: 'Dashboard'),
                SidebarXItem(icon: Icons.book, label: 'Libros'),
                SidebarXItem(icon: Icons.volunteer_activism, label: 'Donaciones'),
                SidebarXItem(icon: Icons.shopping_cart, label: 'Ventas'),
                SidebarXItem(icon: Icons.analytics, label: 'Analisis'),
                SidebarXItem(icon: Icons.settings, label: 'Configuración'),
                SidebarXItem(icon: Icons.logout, label: 'Cerrar sesión'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}