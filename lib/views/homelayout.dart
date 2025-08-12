import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:sidebarx/sidebarx.dart';
import '../views/dashboard.dart';
import '../views/inventario.dart';
import '../views/donaciones.dart';
import '../views/ventas.dart';
import '../views/analisis.dart';
import '../views/settings.dart';
import '../views/detailsbk.dart';
import '../models/bookM.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  final SidebarXController _controller = SidebarXController(selectedIndex: 0);
  Book? selectedBook;
  bool showingDetail = false;

  final List<String> labels = [
    'Dashboard',
    'Libros',
    'Donaciones',
    'Ventas',
    'Analisis',
    'Configuracion',
    'Log out',
  ];

  void handleBookSelection(Book book) {
    setState(() {
      selectedBook = book;
      showingDetail = true;
    });
  }

  Widget getView(int index) {
    if (showingDetail && selectedBook != null) {
      return DetalleLibroPage(
        book: selectedBook!,
        onBack: () => setState(() => showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }

    final selectedLabel = labels[index];

    if (selectedLabel == 'Log out') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox(key: ValueKey('Logout'));
    }

    switch (index) {
      case 0:
        return const Dashboard(key: ValueKey('Dashboard'));
      case 1:
        return InventarioPage(
          key: const ValueKey('Libros'),
          onBookSelected: handleBookSelection,
        );
      case 2:
        return const DonacionesPage(key: ValueKey('Donaciones'));
      case 3:
        return const VentasPage(key: ValueKey('Ventas'));
      case 4:
        return const AnalisisPage(key: ValueKey('Analisis'));
      case 5:
        return const SettingsPage(key: ValueKey('Configuracion'));
      default:
        return const Center(child: Text('Vista no encontrada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(controller: _controller),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: getView(_controller.selectedIndex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}