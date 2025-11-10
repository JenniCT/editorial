import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// WIDGETS
import '../widgets/global/sidebar.dart';
// MODELO
import '../models/book_m.dart';
import '../models/user.dart';

// VISTAS
import 'dashboard/dashboard.dart';
import 'stock/stock.dart';
import 'acervo/acervo.dart';
import 'sales/sales.dart';
import 'users/users.dart';
import 'donation/donation.dart';
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

  Map<String, bool> permisosModulos = {};
  bool loadingPermisos = true;

  // Nuevo estado para el modo oscuro
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _cargarPermisos();
    // Inicializamos según el tema del sistema
    isDarkMode =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  }

  Future<void> _cargarPermisos() async {
    setState(() => loadingPermisos = true);
    Map<String, bool> permisos = {'Dashboard': true, 'Log out': true};
    if (widget.role == Role.adm) {
      setState(() {
        permisosModulos = {
          'Dashboard': true,
          'Inventario': true,
          'Acervo': true,
          'Ventas': true,
          'Donaciones': true,
          'Usuarios': true,
          'Log out': true,
        };
        loadingPermisos = false;
      });
      return;
    }
    try {
      final permisosSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('permissions')
          .get();

      for (var doc in permisosSnapshot.docs) {
        final data = doc.data();
        final modulo = data['module'] as String? ?? '';
        final perms = Map<String, bool>.from(data['permissions'] ?? {});
        permisos[modulo] = perms.values.any((v) => v == true);
      }

      setState(() {
        permisosModulos = permisos;
        loadingPermisos = false;
      });
    } catch (e) {
      setState(() {
        loadingPermisos = false;
      });
    }
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void onItemSelected(int index) {
    final label = labels[index];
    if (!_tieneAccesoModulo(label)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos para acceder a este módulo'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      selectedIndex = index;
    });
  }

  bool _tieneAccesoModulo(String label) {
    if (label == 'Dashboard' || label == 'Log out') return true;
    if (widget.role == Role.adm) return true;
    return permisosModulos[label] ?? false;
  }

  final List<String> labels = [
    'Dashboard',
    'Inventario',
    'Acervo',
    'Ventas',
    'Donaciones',
    'Usuarios',
    'Log out',
  ];

  void handleBookSelection(Book book) {
    setState(() {
      selectedBook = book;
      showingDetail = true;
    });
  }

  void handleUserSelection(UserModel user) {}

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
          key: const ValueKey('Inventario'),
          onBookSelected: handleBookSelection,
        );
      case 2:
        return AcervoPage(
          key: const ValueKey('Acervo'),
          onAcervoSelected: handleBookSelection,
        );
      case 3:
        return const SalesPage(key: ValueKey('Ventas'));
      case 4:
        return const DonationsPage(key: ValueKey('Donaciones'));
      case 5:
        return UsersPage(
          key: const ValueKey('Usuarios'),
          onUsuarioSelected: handleUserSelection,
        );
      default:
        return const Center(child: Text('Vista no encontrada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingPermisos) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: onItemSelected,
            userEmail: widget.user.email,
            userRole: widget.user.roleName,
            permisosModulos: permisosModulos,
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF2F3F5), 
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
          ),
        ],
      ),
    );

  }
}
