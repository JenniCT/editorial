import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  // Mapa de permisos: nombreModulo -> tiene al menos un permiso activo
  Map<String, bool> permisosModulos = {};
  bool loadingPermisos = true;

  @override
  void initState() {
    super.initState();
    _cargarPermisos();
  }

  Future<void> _cargarPermisos() async {
    setState(() => loadingPermisos = true);

    // Dashboard y Log out siempre disponibles para todos
    Map<String, bool> permisos = {
      'Dashboard': true,
      'Log out': true,
    };

    // Si es admin, tiene acceso a todo
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

    // Para otros roles, consultar Firestore
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
        
        // El módulo está habilitado si tiene al menos un permiso activo
        final tienePermisoActivo = perms.values.any((v) => v == true);
        permisos[modulo] = tienePermisoActivo;
      }

      setState(() {
        permisosModulos = permisos;
        loadingPermisos = false;
        debugPrint('Permisos cargados: $permisos');
      });
    } catch (e) {
      debugPrint('Error cargando permisos: $e');
      setState(() {
        loadingPermisos = false;
      });
    }
  }

  void onItemSelected(int index) {
    final label = labels[index];
    
    // Verificar si el módulo está habilitado
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
    // Dashboard y Log out siempre están disponibles
    if (label == 'Dashboard' || label == 'Log out') return true;
    
    // Admin tiene acceso a todo
    if (widget.role == Role.adm) return true;
    
    // Verificar permisos del módulo
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

  void handleUserSelection(UserModel user) {
    // Aquí puedes manejar la acción al seleccionar un usuario
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
      return const Scaffold(
        backgroundColor: Color.fromRGBO(199, 217, 229, 1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                permisosModulos: permisosModulos,
                labels: labels,
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