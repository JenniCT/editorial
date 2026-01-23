import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
import '../../models/user.dart';

//=========================== VISTAMODELOS ===========================//
import '../../viewmodels/users/add_user_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
import '../users/add_user.dart';
import 'details_user.dart';
import '../basic/import/import.dart';
import '../basic/export/download_dialog.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== SUBCOMPONENTES ===========================//
import 'user_table.dart';

//===============================================================//
//                        USERS PAGE
//===============================================================//
class UsersPage extends StatefulWidget {
  final Function(UserModel) onUsuarioSelected;
  const UsersPage({required this.onUsuarioSelected, super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  //=========================== CONTROLADORES Y ESTADOS ===========================//
  late final AddUserVM _viewModel;
  final ExportViewModel _exportVM = ExportViewModel();
  final TextEditingController _searchController = TextEditingController();
  
  // CLAVE PARA ACCEDER AL ESTADO DE LA TABLA Y SUS SELECCIONES
  final GlobalKey<UsersTableState> _tableKey = GlobalKey<UsersTableState>();
  
  List<UserModel> _allUsuarios = [];
  int selectedUsersCount = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = AddUserVM();
    _loadUsuarios();
  }

  // CARGA INICIAL DE DATOS
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
            //=========================== ENCABEZADO DE PÁGINA ===========================//
            PageHeader(
              title: 'Usuarios',
              buttons: [
                // BOTÓN GENERAR QRS (MANTENIDO POR COHERENCIA)
                HeaderButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),

                //==================== EXPORTAR ====================//
                HeaderButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () async {
                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: _allUsuarios.length,
                      selectedItems: selectedUsersCount,
                      entityName: 'usuarios',
                    );

                    if (option == null) return;

                    // EXPORTACIÓN DE TODOS LOS USUARIOS
                    if (option == 'all') {
                      final allData = _viewModel.mapUsersToExport(_allUsuarios);
                      
                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: allData,
                        fileName: 'usuarios_completos',
                        context: context,
                      );

                    // EXPORTACIÓN SOLO DE SELECCIONADOS
                    } else if (option == 'selected') {
                      final selectedList = _tableKey.currentState?.selectedUsers ?? [];
                      
                      if (selectedList.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No hay usuarios seleccionados para exportar')),
                        );
                        return;
                      }

                      final selectedData = _viewModel.mapUsersToExport(selectedList);

                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: selectedData,
                        fileName: 'usuarios_seleccionados',
                        context: context,
                      );
                    }
                  },
                  type: ActionType.secondary,
                ),

                //==================== IMPORTAR ====================//
                HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ImportDialog(
                      entityName: 'usuarios',
                      onImportConfirmed: (List<Map<String, dynamic>> data) async {
                        try {
                          for (var row in data) {
                            // 1. Limpieza de datos: Eliminamos espacios en blanco de las llaves
                            final cleanRow = row.map((key, value) => MapEntry(key.trim(), value));

                            // 2. Mapeo manual basado en tu formato de EXPORTACIÓN
                            // Importante: Las llaves deben ser idénticas a las del método mapUsersToExport
                            final String email = cleanRow['Correo Electrónico']?.toString() ?? "";
                            
                            if (email.isEmpty || !email.contains('@')) continue; // Saltar filas inválidas

                            final newUser = UserModel(
                              uid: '', // Se genera en el AddUserVM
                              name: cleanRow['Nombre Completo']?.toString() ?? 'Sin Nombre',
                              email: email,
                              password: 'TemporalPassword123!', // Password por defecto
                              role: _parseRole(cleanRow['Rol de Usuario']?.toString()),
                              createAt: DateTime.now(),
                              status: cleanRow['Estado']?.toString().toUpperCase() == 'ACTIVO',
                            );

                            // 3. Guardado secuencial
                            await _viewModel.addUsuario(newUser);
                          }
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Importación completada con éxito'))
                            );
                            _loadUsuarios(); // Recargar la tabla
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error en la importación: $e'), backgroundColor: Colors.red)
                            );
                          }
                        }
                      },
                    ),
                  ),
                  type: ActionType.secondary,
                ),
                //==================== AGREGAR USUARIO ====================//
                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar usuario',
                  onPressed: () async {
                    await showAddUserDialog(context);
                    await _loadUsuarios(); // Recarga la lista tras agregar
                  },
                  type: ActionType.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            //=========================== TABLA DE USUARIOS ===========================//
            Expanded(
              child: UsersTable(
                key: _tableKey, // ASIGNACIÓN DE LA LLAVE GLOBAL
                allUsuarios: _allUsuarios,
                searchController: _searchController,
                onSelectionChanged: (count) {
                  setState(() => selectedUsersCount = count);
                },
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

  Role _parseRole(String? roleStr) {
    if (roleStr == null) return Role.staff;
    switch (roleStr.toUpperCase()) {
      case 'ADMIN': return Role.adm;
      case 'STAFF': return Role.staff;
      default: return Role.staff;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}