import 'package:flutter/material.dart';

// WIDGETS
import '../widgets/global/sidebar.dart';
import '../widgets/global/background.dart';

// MODELO
import '../models/book_m.dart';
import '../models/user.dart';

// VISTAS
import 'dashboard/dashboard.dart';
import 'stock/stock.dart';
import 'acervo/acervo.dart';
import 'market/sales.dart';
import 'users/analisis.dart';
import 'setting/settings.dart';
import 'book/details_bk.dart';

class HomeLayout extends StatefulWidget {
  final UserModel user;
  final Role role;
  const HomeLayout({required this.user, required this.role, super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int selectedIndex = 0;
  Book? selectedBook;
  bool showingDetail = false;
  
  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<String> labels = [
    'Dashboard',
    'Libros',
    'Acervo',
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
        return AcervoPage(
          key: const ValueKey('Acervo'),
          onAcervoSelected: handleBookSelection, // ahora devuelve Book
        );
      case 3:
        return const SalesPage(key: ValueKey('Ventas'));
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
      backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
      body: Stack(
        children: [
          const BackgroundCircles(), 
          Row(
            children: [
              Sidebar(
                selectedIndex: selectedIndex,
                onItemSelected: onItemSelected,
                userEmail: widget.user.email,
                userRole: widget.user.roleName,
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
                  child: getView(selectedIndex),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
