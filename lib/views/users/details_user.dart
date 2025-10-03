import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../viewmodels/users/details_user_vm.dart';
import '../../widgets/global/background.dart';

class DetailsUserPage extends StatefulWidget {
  final UserModel usuario;
  final VoidCallback onBack;

  const DetailsUserPage({
    required this.usuario,
    required this.onBack,
    super.key,
  });

  @override
  State<DetailsUserPage> createState() => _DetailsUserPageState();
}

class _DetailsUserPageState extends State<DetailsUserPage> {
  late UserModel usuario;
  late DetalleUsuarioVM viewModel;

  List<String> acciones = ["Ver", "Editar", "Eliminar"];
  List<String> module = [];
  Map<String, Map<String, bool>> permisos = {}; // módulo -> acción -> estado

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
    viewModel = DetalleUsuarioVM(usuario: usuario);
    _cargarModulosYPermisos();
  }

  /// Cargar módulos y permisos
  Future<void> _cargarModulosYPermisos() async {
    // 1. Cargar módulos
    final modulesSnapshot = await FirebaseFirestore.instance.collection('modules').get();
    final mods = modulesSnapshot.docs.map((d) => d['name'] as String).toList();

    // 2. Inicializar permisos por módulo
    Map<String, Map<String, bool>> permisosTemp = {};
    for (var m in mods) {
      permisosTemp[m] = {for (var a in acciones) a: false};
    }

    // 3. Cargar permisos del usuario
    final permisosSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(usuario.uid)
        .collection('permissions')
        .get();

    for (var doc in permisosSnapshot.docs) {
      final data = doc.data();
      final mod = data['module'] as String? ?? '';
      final perms = Map<String, bool>.from(data['permissions'] ?? {});
      if (mod.isNotEmpty && permisosTemp.containsKey(mod)) {
        permisosTemp[mod] = perms;
      }
    }

    setState(() {
      module = mods;
      permisos = permisosTemp;
    });
  }

  /// Actualizar permisos en Firestore
  Future<void> _actualizarPermiso(String modulo, String accion, bool value) async {
    setState(() {
      permisos[modulo]![accion] = value;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(usuario.uid)
        .collection('permissions')
        .doc(modulo)
        .set({
      'module': modulo,
      'permissions': permisos[modulo],
    });
  }

  void _updateUsuario(UserModel updatedUser) {
    setState(() {
      usuario = updatedUser;
      viewModel = DetalleUsuarioVM(usuario: usuario);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Detalles del Usuario', style: TextStyle(fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, size: 28), onPressed: widget.onBack),
      ),
      body: Stack(
        children: [
          const BackgroundCircles(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetallesUsuarioCard(),
                  const SizedBox(height: 24),
                  _buildAccionesUsuario(),
                  const SizedBox(height: 24),
                  _buildTablaPermisos(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesUsuarioCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(47, 65, 87, 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(usuario.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(usuario.email, style: const TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                children: [
                  _buildRow("Rol", usuario.roleName),
                  _buildRow("Estado", usuario.status ? "Activo" : "Inactivo"),
                  _buildRow("Creado", viewModel.formatDate(usuario.createAt)),
                  _buildRow("Expira", usuario.expiresAt != null ? viewModel.formatDate(usuario.expiresAt!) : "No asignado"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text("$label:", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(value, style: const TextStyle(color: Colors.white))),
      ],
    );
  }

  Widget _buildAccionesUsuario() {
    return Row(
      children: [
        _buildActionButton(Icons.edit, "Editar", color: Colors.orange, onPressed: () {
          viewModel.editarUsuario(context, _updateUsuario);
        }),
        const SizedBox(width: 12),
        _buildActionButton(Icons.remove_circle, "Dar de baja", color: Colors.red),
      ],
    );
  }

  Widget _buildTablaPermisos() {
    return permisos.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Table(
            border: TableBorder.all(color: Colors.white38),
            columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(), 2: FlexColumnWidth(), 3: FlexColumnWidth()},
            children: [
              // Header
              TableRow(
                decoration: const BoxDecoration(color: Color.fromRGBO(47, 65, 87, 0.9)),
                children: [
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("Módulo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ...acciones.map((a) => Padding(padding: const EdgeInsets.all(8.0), child: Text(a, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                ],
              ),
              // Filas de módulos
              ...module.map((mod) {
                return TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(mod, style: const TextStyle(color: Colors.white70))),
                    ...acciones.map((accion) {
                      final checked = permisos[mod]?[accion] ?? false;
                      return Checkbox(
                        value: checked,
                        onChanged: (v) => _actualizarPermiso(mod, accion, v ?? false),
                        fillColor: MaterialStateProperty.all(Colors.blueAccent),
                      );
                    }),
                  ],
                );
              }),
            ],
          );
  }

  Widget _buildActionButton(IconData icon, String label, {Color? color, VoidCallback? onPressed}) {
    return Container(
      width: 160,
      height: 48,
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.4)),
      ),
      child: InkWell(
        onTap: onPressed ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ]),
      ),
    );
  }
}
