import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../viewmodels/users/details_user_vm.dart';
import '../../widgets/table/table.dart';

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

  List<String> acciones = ["Ver", "Editar", "Eliminar", "Agregar"];
  List<String> module = [];
  Map<String, Map<String, bool>> permisos = {}; 
  bool loading = true;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
    viewModel = DetalleUsuarioVM(usuario: usuario);
    _cargarModulosYPermisos();
  }

  Future<void> _cargarModulosYPermisos() async {
    setState(() => loading = true);

    final modulesSnapshot = await FirebaseFirestore.instance.collection('modules').get();
    final mods = modulesSnapshot.docs.map((d) => d['name'] as String).toList();

    Map<String, Map<String, bool>> permisosTemp = {};
    for (var m in mods) {
      permisosTemp[m] = {for (var a in acciones) a: false};
    }

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
      loading = false;
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Detalles del Usuario', style: TextStyle(fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, size: 28), onPressed: widget.onBack),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetallesUsuarioCard(),
                        const SizedBox(height: 24),
                        _buildAccionesUsuario(),
                        const SizedBox(height: 24),
                        _buildTablaPermisos(),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text("Guardar cambios"),
                            onPressed: () async {
                              final errores = viewModel.validarPermisosAvanzado(permisos);
                              if (errores.values.any((e) => e != null)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Corrige los permisos marcados en rojo")),
                                );
                                return;
                              }

                              await viewModel.guardarPermisos(permisos);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Permisos guardados correctamente")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
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
    final errores = viewModel.validarPermisosAvanzado(permisos);

    return CustomTable(
      headers: ["Módulo", ...acciones],
      rows: module.map((mod) {
        final errorMsg = errores[mod];
        return [
          Tooltip(
            message: errorMsg ?? '',
            child: Container(
              color: errorMsg != null ? const Color.fromRGBO(255, 82, 82, 0.2) : null,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(mod, style: const TextStyle(color: Colors.white)),
            ),
          ),
          ...acciones.map((accion) {
            final checked = permisos[mod]?[accion] ?? false;
            final bloqueado = usuario.role == Role.guest && accion == "Eliminar";

            return StatefulBuilder(
              builder: (context, setStateCheckbox) {
                return Tooltip(
                  message: bloqueado ? "Acción no permitida para ${usuario.roleName}" : errorMsg ?? '',
                  child: Checkbox(
                    value: checked,
                    onChanged: bloqueado
                        ? null
                        : (v) {
                            setState(() {
                              permisos[mod]![accion] = v ?? false;
                            });
                            setStateCheckbox(() {});
                          },
                    fillColor: MaterialStateProperty.all(bloqueado ? Colors.grey : Colors.blueAccent),
                  ),
                );
              },
            );
          }),
        ];
      }).toList(),
      columnWidths: [200, 80, 80, 80],
    );
  }

  Widget _buildActionButton(IconData icon, String label, {Color? color, VoidCallback? onPressed}) {
    return Container(
      width: 160,
      height: 48,
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withValues(alpha: 0.6),
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
