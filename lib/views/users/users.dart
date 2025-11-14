import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
import '../../models/user.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
import '../users/add_user.dart';
import 'details_user.dart';
import '../basic/import/import.dart';
import '../basic/export/export.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== SUBCOMPONENTES ===========================//
import 'user_table.dart';
import '../../viewmodels/users/add_user_vm.dart';

class UsersPage extends StatefulWidget {
  final Function(UserModel) onUsuarioSelected;
  const UsersPage({required this.onUsuarioSelected, super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final AddUserVM _viewModel;
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allUsuarios = [];

  @override
  void initState() {
    super.initState();
    _viewModel = AddUserVM();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    final usuarios = await _viewModel.getUsuariosFirebase();
    if (mounted) {
      setState(() {
        _allUsuarios = usuarios;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //=========================== CABECERA ===========================//
            PageHeader(
              title: 'Libros',
              buttons: [
                // BOTÓN PARA GENERAR CÓDIGOS QR
                HeaderButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),
                // BOTÓN PARA EXPORTAR CSV
                HeaderButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ExportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),
                // BOTÓN PARA IMPORTAR CSV
                HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ImportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),
                // BOTÓN PRINCIPAL PARA AGREGAR NUEVO USUARIO
                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar usuario',
                  onPressed: () async {
                    await showAddUserDialog(context);
                    await _loadUsuarios();
                  },
                  type: ActionType.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            //=========================== TABLA DE USUARIOS ===========================//
            Expanded(
              child: UsersTable(
                allUsuarios: _allUsuarios,
                searchController: _searchController,
                onUserSelected: (usuario) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailsUserPage(
                        usuario: usuario,
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
