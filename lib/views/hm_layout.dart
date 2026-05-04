import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// WIDGETS
import '../widgets/global/sidebar.dart';

// MODELOS
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

  const HomeLayout({
    required this.user,
    required this.role,
    super.key,
  });

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int selectedIndex = 0;
  Book? selectedBook;
  bool showingDetail = false;
  Map<String, bool> permisosModulos = {};
  bool loadingPermisos = true;

  final List<Widget?> loadedPages = [];

  // KEY PARA CONTROLAR EL SCAFFOLD Y EL DRAWER
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  final List<String> labels = [
    'Dashboard',
    'Inventario',
    'Acervo',
    'Ventas',
    'Donaciones',
    'Usuarios',
    'Cerrar sesión',
  ];

  @override
  void initState() {
    super.initState();

    loadedPages.addAll(
      List<Widget?>.filled(
        labels.length - 1,
        null,
        growable: false,
      ),
    );

    // Dashboard precargado
    loadedPages[0] = const Dashboard();

    _cargarPermisos();
  }

  Future<void> _cargarPermisos() async {
    setState(() => loadingPermisos = true);

    Map<String, bool> permisos = {
      'Dashboard': true,
      'Cerrar sesión': true,
    };

    // ADMIN: acceso total
    if (widget.role == Role.adm) {
      setState(() {
        permisosModulos = {
          'Dashboard': true,
          'Inventario': true,
          'Acervo': true,
          'Ventas': true,
          'Donaciones': true,
          'Usuarios': true,
          'Cerrar sesión': true,
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

        final perms = Map<String, bool>.from(
          data['permissions'] ?? {},
        );

        permisos[modulo] =
            perms.values.any((value) => value == true);
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

  bool _tieneAccesoModulo(String label) {
    if (label == 'Dashboard' ||
        label == 'Cerrar sesión') {
      return true;
    }

    if (widget.role == Role.adm) {
      return true;
    }

    return permisosModulos[label] ?? false;
  }

  void handleBookSelection(Book book) {
    setState(() {
      selectedBook = book;
      showingDetail = true;
    });
  }

  Future<void> onItemSelected(int index) async {
    final label = labels[index];

    // CERRAR SESIÓN REAL
    if (label == 'Cerrar sesión') {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );

      return;
    }

    // VALIDAR PERMISOS
    if (!_tieneAccesoModulo(label)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      selectedIndex = index;
      showingDetail = false;

      if (index < loadedPages.length &&
          loadedPages[index] == null) {
        loadedPages[index] = _buildPage(index);
      }
    });

    // CERRAR DRAWER EN MÓVIL
    if (_scaffoldKey.currentState?.isDrawerOpen ??
        false) {
      Navigator.pop(context);
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const Dashboard();

      case 1:
        return InventarioPage(
          onBookSelected: handleBookSelection,
        );

      case 2:
        return AcervoPage(
          onAcervoSelected: handleBookSelection,
        );

      case 3:
        return const SalesPage();

      case 4:
        return const DonationsPage();

      case 5:
        return UsersPage(
          onUsuarioSelected: (u) {},
        );

      default:
        return const Center(
          child: Text('Vista no encontrada'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingPermisos) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isMobile =
        MediaQuery.of(context).size.width < 800;

    return Scaffold(
      key: _scaffoldKey,

      // DRAWER PARA MÓVIL
      drawer: isMobile
          ? Sidebar(
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
              userName: widget.user.name,
              userRole: widget.user.roleName,
              permisosModulos: permisosModulos,
            )
          : null,

      // APPBAR PARA MÓVIL
      appBar: isMobile
          ? AppBar(
              backgroundColor:
                  const Color(0xFF1C2532),
              title: Text(
                labels[selectedIndex],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              elevation: 0,
            )
          : null,

      body: Row(
        children: [
          // SIDEBAR EN ESCRITORIO
          if (!isMobile)
            Sidebar(
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
              userName: widget.user.name,
              userRole: widget.user.roleName,
              permisosModulos: permisosModulos,
            ),

          Expanded(
            child: Container(
              color: const Color(0xFFF2F3F5),

              child: showingDetail &&
                      selectedBook != null
                  ? DetalleLibroPage(
                      key: const ValueKey(
                        'DetalleLibro',
                      ),
                      book: selectedBook!,
                      onBack: () {
                        setState(() {
                          showingDetail = false;
                        });
                      },
                    )
                  : IndexedStack(
                      index: selectedIndex,
                      children: List.generate(
                        loadedPages.length,
                        (index) =>
                            loadedPages[index] ??
                            const SizedBox(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
