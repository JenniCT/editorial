import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

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

//=========================== WIDGETS ===========================//
import '../../widgets/layout/page_header.dart';

import '../../widgets/buttons/primary_btn.dart';
import '../../widgets/buttons/secondary_btn.dart';

import '../../widgets/modules/table.dart';
import '../../widgets/modules/table_text.dart';
import '../../widgets/modules/table_checkbox.dart';
import '../../widgets/modules/table_actions.dart';

import '../../widgets/global/search.dart';
import '../../widgets/modules/pagination.dart';

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

  // LISTAS
  List<UserModel> _allUsuarios = [];
  List<UserModel> _filteredUsuarios = [];

  // BÚSQUEDA
  bool _isSearching = false;

  // SELECCIÓN
  bool _selectAll = false;
  int _selectedCount = 0;

  // PAGINACIÓN
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  //=========================== INIT ===========================//
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

  //=========================== SELECCIÓN ===========================//
  List<UserModel> get _selectedUsers =>
      _allUsuarios.where((u) => u.selected).toList();

  void _updateSelectedCount() {
    if (mounted) {
      setState(() {
        _selectedCount = _selectedUsers.length;
      });
    }
  }

  //=========================== BÚSQUEDA ===========================//
  void _handleSearchResults(List<UserModel> results) {
    setState(() {
      _filteredUsuarios = results;
      _isSearching =
          results.isNotEmpty || _searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  //=========================== CELDAS ===========================//
  Widget _buildClickableCell(Widget child, UserModel user) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsUserPage(
              usuario: user,
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }

  //=========================== CABECERAS ===========================//
  List<Widget> _buildHeaders(bool enableSelectAll) {
    return [
      IconButton(
        icon: Icon(
          _selectAll
              ? Icons.check_box_outlined
              : Icons.check_box_outline_blank_outlined,
          color: Colors.white,
        ),
        onPressed: enableSelectAll
            ? () {
                setState(() {
                  _selectAll = !_selectAll;

                  // APLICA SOLO A LA PÁGINA ACTUAL
                  final itemsToShow =
                      _isSearching ? _filteredUsuarios : _allUsuarios;
                  final start = _currentPage * _itemsPerPage;
                  final end =
                      (start + _itemsPerPage).clamp(0, itemsToShow.length);
                  final pageItems = itemsToShow.sublist(start, end);

                  for (var user in pageItems) {
                    user.selected = _selectAll;
                  }
                });
                _updateSelectedCount();
              }
            : null,
      ),
      const Text('Nombre'),
      const Text('Correo'),
      const Text('Creación'),
      const Text('Expiración'),
      const Text('Estado'),
      const Text('Acciones'),
    ];
  }

  //=========================== PARSE ROLE ===========================//
  Role _parseRole(String? roleStr) {
    if (roleStr == null) return Role.staff;
    switch (roleStr.toUpperCase()) {
      case 'ADMIN':
        return Role.adm;
      case 'STAFF':
        return Role.staff;
      default:
        return Role.staff;
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[
      60,  // checkbox
      180, // nombre
      240, // email
      130, // creación
      130, // expiración
      120, // estado
      220, // acciones
    ];
    final List<UserModel> itemsToShow =
        _isSearching ? _filteredUsuarios : _allUsuarios;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
    final usuariosPage = itemsToShow.isNotEmpty
        ? itemsToShow.sublist(startIndex, endIndex)
        : <UserModel>[];

    _selectAll =
        usuariosPage.isNotEmpty && usuariosPage.every((u) => u.selected);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== ENCABEZADO ===========================//
            PageHeader(
              title: 'Usuarios',
              actions: [

                //==================== IMPORTAR ====================//
                SecondaryButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ImportDialog(
                      entityName: 'usuarios',
                      onImportConfirmed:
                          (List<Map<String, dynamic>> data) async {
                        try {
                          for (var row in data) {
                            final cleanRow = row.map(
                                (key, value) => MapEntry(key.trim(), value));

                            final String email =
                                cleanRow['Correo Electrónico']?.toString() ??
                                    '';

                            if (email.isEmpty || !email.contains('@')) {
                              continue;
                            }

                            final newUser = UserModel(
                              uid: '',
                              name: cleanRow['Nombre Completo']?.toString() ??
                                  'Sin Nombre',
                              email: email,
                              password: 'TemporalPassword123!',
                              role: _parseRole(
                                  cleanRow['Rol de Usuario']?.toString()),
                              createAt: DateTime.now(),
                              status: cleanRow['Estado']
                                      ?.toString()
                                      .toUpperCase() ==
                                  'ACTIVO',
                            );

                            await _viewModel.addUsuario(newUser);
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Importación completada con éxito')),
                            );
                            _loadUsuarios();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error en la importación: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),

                //==================== EXPORTAR ====================//
                SecondaryButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () async {
                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: _allUsuarios.length,
                      selectedItems: _selectedCount,
                      entityName: 'usuarios',
                    );

                    if (option == null) return;

                    if (option == 'all') {
                      final allData =
                          _viewModel.mapUsersToExport(_allUsuarios);
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: allData,
                        fileName: 'usuarios_completos',
                        context: context,
                      );
                    } else if (option == 'selected') {
                      if (_selectedUsers.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'No hay usuarios seleccionados para exportar')),
                        );
                        return;
                      }
                      final selectedData =
                          _viewModel.mapUsersToExport(_selectedUsers);
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: selectedData,
                        fileName: 'usuarios_seleccionados',
                        context: context,
                      );
                    }
                  },
                ),

                //==================== GENERAR QRS ====================//
                SecondaryButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                ),

                //==================== AGREGAR ====================//
                PrimaryButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar usuario',
                  onPressed: () async {
                    await showAddUserDialog(context);
                    await _loadUsuarios();
                  },
                ),
              
              ],
            ),

            const SizedBox(height: 20),

            //=========================== BÚSQUEDA, FILTRO Y ORDEN ===========================//
            Row(
              children: [
                //==================== BÚSQUEDA ====================//
                Expanded(
                  child: Search<UserModel>(
                    controller: _searchController,
                    hintText: 'Buscar por nombre, email, rol, etc.',
                    allItems: _allUsuarios,
                    onResults: _handleSearchResults,
                    filter: (user, query) {
                      final q = query.toLowerCase();
                      return user.name.toLowerCase().contains(q) ||
                          user.email.toLowerCase().contains(q) ||
                          user.role
                              .toString()
                              .split('.')
                              .last
                              .toLowerCase()
                              .contains(q);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                //==================== FILTRAR====================//
                SecondaryButton(
                  icon: Icons.filter_list,
                  text: 'Filtrar',
                  onPressed: () {},
                ),
                const SizedBox(width: 12),

                //==================== ORDENAR ====================//
                SecondaryButton(
                  icon: Icons.sort,
                  text: 'Ordenar',
                  onPressed: () {},
                ),
              
              ],
            ),

            const SizedBox(height: 16),

            //=========================== TABLA ===========================//
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //=========================== CONTADOR DE SELECCIONADOS ===========================//
                    if (_selectedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8),
                        child: Text(
                          '$_selectedCount usuario(s) seleccionado(s)',
                          style: const TextStyle(
                            color: Color(0xFF1C2532),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    CustomTable(
                      headers: _buildHeaders(itemsToShow.isNotEmpty),
                      rows: usuariosPage.map((user) {
                        return [
                          //=========================== CHECKBOX ===========================//
                          TableCheckbox(
                            value: user.selected,
                            onTap: () {
                              setState(() {
                                user.selected = !user.selected;
                              });
                                _updateSelectedCount();
                            },
                          ),

                          //=========================== COLUMNAS DE TEXTO ===========================//
                          _buildClickableCell(TableText(text: user.name), user),
                          _buildClickableCell(TableText(text: user.email), user),
                          _buildClickableCell(TableText(text: DateFormat('dd/MM/yyyy').format(user.createAt)),user),
                          _buildClickableCell(TableText(text: user.expiresAt != null ? DateFormat('dd/MM/yyyy').format(user.expiresAt!): 'No asignado',), user,),
                          _buildClickableCell(TableText(text: user.status ? 'Activo' : 'Inactivo'), user),
                          TableActions(
                            showCost: false,
                            showQR: false,
                            onEdit: () {},
                            onQr: () {},
                            onHistory: () {},
                            onDelete: () {},
                          ),
                        ];
                      }).toList(),
                      columnWidths: columnWidths,
                      width: 1200,
                    ),

                    //=========================== PAGINACIÓN ===========================//
                    if (itemsToShow.length > _itemsPerPage)
                      PaginationWidget(
                        currentPage: _currentPage,
                        totalItems: itemsToShow.length,
                        itemsPerPage: _itemsPerPage,
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                      ),

                    //=========================== RESULTADOS DE BÚSQUEDA ===========================//
                    if (_isSearching)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Mostrando ${itemsToShow.length} resultado(s)',
                          style: const TextStyle(
                            color: Color(0xFF1C2532),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
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