import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../views/dashboard.dart';
import '../views/inventario.dart';
import '../views/donaciones.dart';
import '../views/ventas.dart';
import '../views/analisis.dart';
import '../views/settings.dart';
import '../views/detailsbk.dart';
import '../models/bookdata.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  String selectedView = 'Dashboard';
  BookData? selectedBook;

  void onItemSelected(String item) {
    if (item == 'Log out') {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        selectedView = item;
        selectedBook = null; // Limpiar selección si no es detalle
      });
    }
  }

  void handleBookSelection(BookData book) {
    setState(() {
      selectedBook = book;
      selectedView = 'DetalleLibro';
    });
  }

  Widget getView() {
    if (selectedView == 'DetalleLibro' && selectedBook != null) {
      return DetalleLibroPage(
        book: selectedBook!,
        onBack: () => setState(() => selectedView = 'Libros'),
      );
    }

    switch (selectedView) {
      case 'Dashboard':
        return const Dashboard();
      case 'Libros':
        return InventarioPage(onBookSelected: handleBookSelection); // ✅ Pasamos la función correctamente
      case 'Donaciones':
        return const DonacionesPage();
      case 'Ventas':
        return const VentasPage();
      case 'Analisis':
        return const AnalisisPage();
      case 'Configuracion':
        return const SettingsPage();
      default:
        return const Center(child: Text('Vista no encontrada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selected: selectedView,
            onItemSelected: onItemSelected,
          ),
          Expanded(
            child: AnimatedSwitcher(
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
              child: getView(),
            ),
          ),
        ],
      ),
    );
  }
}