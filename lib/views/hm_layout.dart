import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // precarga dashboard
    loadedPages[0] = const Dashboard();

    _cargarPermisos().then((_) {
      _restoreSelectedIndex();
    });
  }

  // =====================================================
  // GUARDAR PÁGINA ACTUAL
  // =====================================================

  Future<void> _saveSelectedIndex(
    int index,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      'home_selected_index',
      index,
    );
  }

  Future<void> _restoreSelectedIndex() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedIndex =
        prefs.getInt(
              'home_selected_index',
            ) ??
            0;

    if (!mounted) return;

    setState(() {
      selectedIndex = savedIndex;

      if (savedIndex < loadedPages.length &&
          loadedPages[savedIndex] == null) {
        loadedPages[savedIndex] =
            _buildPage(savedIndex);
      }
    });
  }

  Future<void> _clearSavedIndex() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      'home_selected_index',
    );
  }

  // =====================================================
  // PERMISOS
  // =====================================================

  Future<void> _cargarPermisos() async {
    if (!mounted) return;

    setState(() => loadingPermisos = true);

    Map<String, bool> permisos = {
      'Dashboard': true,
      'Cerrar sesión': true,
    };

    // ADMIN → acceso total
    if (widget.role == Role.adm) {
      if (!mounted) return;

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
      final permisosSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.uid)
              .collection('permissions')
              .get();

      for (final doc in permisosSnapshot.docs) {
        final data = doc.data();

        final modulo =
            data['module'] as String? ?? '';

        final perms =
            Map<String, bool>.from(
          data['permissions'] ?? {},
        );

        permisos[modulo] =
            perms.values.any(
          (value) => value == true,
        );
      }

      if (!mounted) return;

      setState(() {
        permisosModulos = permisos;
        loadingPermisos = false;
      });
    } catch (e) {
      if (!mounted) return;

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

  // =====================================================
  // DETALLE LIBRO
  // =====================================================

  void handleBookSelection(Book book) {
    setState(() {
      selectedBook = book;
      showingDetail = true;
    });
  }

  // =====================================================
  // NAVEGACIÓN
  // =====================================================

  Future<void> onItemSelected(
    int index,
  ) async {
    final label = labels[index];

    // =========================================
    // CERRAR SESIÓN
    // =========================================

    if (label == 'Cerrar sesión') {
      await _clearSavedIndex();

      await FirebaseAuth.instance
          .signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );

      return;
    }

    // =========================================
    // VALIDAR PERMISOS
    // =========================================

    if (!_tieneAccesoModulo(label)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('No tienes permisos'),
          backgroundColor:
              Colors.redAccent,
        ),
      );

      return;
    }

    // =========================================
    // CAMBIO DE VISTA
    // =========================================

    setState(() {
      selectedIndex = index;
      showingDetail = false;

      if (index < loadedPages.length &&
          loadedPages[index] == null) {
        loadedPages[index] =
            _buildPage(index);
      }
    });

    await _saveSelectedIndex(index);

    // cerrar drawer móvil
    if (_scaffoldKey
            .currentState
            ?.isDrawerOpen ??
        false) {
      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const Dashboard();

      case 1:
        return InventarioPage(
          onBookSelected:
              handleBookSelection,
        );

      case 2:
        return AcervoPage(
          onAcervoSelected:
              handleBookSelection,
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
          child:
              Text('Vista no encontrada'),
        );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    if (loadingPermisos) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final bool isMobile =
        MediaQuery.of(context).size.width <
            800;

    return Scaffold(
      key: _scaffoldKey,

      // =====================================
      // DRAWER MOBILE
      // =====================================

      drawer: isMobile
          ? Sidebar(
              selectedIndex:
                  selectedIndex,
              onItemSelected:
                  onItemSelected,
              userName:
                  widget.user.name,
              userRole:
                  widget.user.roleName,
              permisosModulos:
                  permisosModulos,
            )
          : null,

      // =====================================
      // APPBAR MOBILE
      // =====================================

      appBar: isMobile
          ? AppBar(
              backgroundColor:
                  const Color(
                0xFF1C2532,
              ),
              title: Text(
                labels[selectedIndex],
                style:
                    const TextStyle(
                  color: Colors.white,
                ),
              ),
              iconTheme:
                  const IconThemeData(
                color: Colors.white,
              ),
              elevation: 0,
            )
          : null,

      // =====================================
      // BODY
      // =====================================

      body: Row(
        children: [
          // sidebar desktop
          if (!isMobile)
            Sidebar(
              selectedIndex:
                  selectedIndex,
              onItemSelected:
                  onItemSelected,
              userName:
                  widget.user.name,
              userRole:
                  widget.user.roleName,
              permisosModulos:
                  permisosModulos,
            ),

          Expanded(
            child: Container(
              color:
                  const Color(0xFFF2F3F5),

              child: showingDetail &&
                      selectedBook != null
                  ? DetalleLibroPage(
                      key:
                          const ValueKey(
                        'DetalleLibro',
                      ),
                      book:
                          selectedBook!,
                      onBack: () {
                        setState(() {
                          showingDetail =
                              false;
                        });
                      },
                    )
                  : IndexedStack(
                      index:
                          selectedIndex,
                      children:
                          List.generate(
                        loadedPages.length,
                        (index) =>
                            loadedPages[
                                    index] ??
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