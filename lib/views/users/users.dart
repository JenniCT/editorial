import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// MODELO
import '../../models/user.dart';
// VIEWMODEL
import '../../viewmodels/users/add_user_vm.dart';
// VISTAS
import '../users/add_user.dart';
import 'details_user.dart';
// WIDGETS
import '../../widgets/global/search.dart';
import '../../widgets/table/table.dart';
import '../../widgets/stock/hoverbutton.dart';

class UsersPage extends StatefulWidget {
  final Function(UserModel) onUsuarioSelected;

  const UsersPage({required this.onUsuarioSelected, super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final AddUserVM _viewModel;
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredUsuarios = [];
  List<UserModel> _allUsuarios = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARRA DE BÚSQUEDA
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Search<UserModel>(
                    controller: _searchController,
                    allItems: _allUsuarios,
                    onResults: (results) {
                      setState(() {
                        _filteredUsuarios = results;
                        _isSearching = results.isNotEmpty || _searchController.text.isNotEmpty;
                        _currentPage = 0;
                      });
                    },
                    filter: (usuario, query) {
                      return usuario.name.toLowerCase().contains(query) ||
                          usuario.email.toLowerCase().contains(query) ||
                          usuario.role.toString().toLowerCase().contains(query);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            // TÍTULO Y BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Usuarios',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      HoverButton(
                        icon: Icons.filter_list,
                        text:  'Filtrar',
                        onPressed: () {},
                        color: Colors.white,),
                      HoverButton(
                        icon:  Icons.download,
                        text:  'Exportar',
                        onPressed: () {},
                        color: Colors.white,
                      ),
                      HoverButton(
                        icon: Icons.upload,
                        text:  'Importar',
                        onPressed: () {},
                        color: Colors.white,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar usuario'),
                        onPressed: () async {
                          await showAddUserDialog(context);
                          await _loadUsuarios();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // TABLA DE USUARIOS
            _buildUsuariosTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsuariosTable() {
    final itemsToShow = _isSearching ? _filteredUsuarios : _allUsuarios;

    if (itemsToShow.isEmpty) {
      return const Center(child: Text('No hay usuarios disponibles'));
    }

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
    final usuariosPage = itemsToShow.sublist(startIndex, endIndex);

    final columnWidths = <double>[200, 250, 100, 150, 180, 120];

    return Column(
      children: [
        CustomTable(
          headers: [
            'Nombre',
            'Email',
            'Rol',
            'Fecha de creación',
            'Fecha de expiración',
            'Estado'
          ],
          rows: usuariosPage.map((usuario) {
            return [
              // 🔹 Hacemos que toda la fila sea "clickeable"
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsUserPage(usuario: usuario, onBack: () => Navigator.pop(context),),
                    ),
                  );
                },
                child: _buildText(usuario.name),
              ),
              _buildText(usuario.email),
              _buildText(usuario.role.toString().split('.').last),
              _buildText(DateFormat('dd/MM/yyyy').format(usuario.createAt)),
              _buildText(
                usuario.expiresAt != null
                    ? DateFormat('dd/MM/yyyy').format(usuario.expiresAt!)
                    : 'No asignado',
              ),
              _buildStatusIcon(usuario.status),
            ];
          }).toList(),
          columnWidths: columnWidths,
        ),

        // PAGINACIÓN
        if (itemsToShow.length > _itemsPerPage)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed:
                      _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                ),
                Text(
                  '${_currentPage + 1} / ${((itemsToShow.length - 1) / _itemsPerPage).ceil() + 1}',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: endIndex < itemsToShow.length
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Mostrando ${itemsToShow.length} resultado(s) de búsqueda',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
      ],
    );
  }



  Widget _buildText(String text) => 
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
    );

  Widget _buildStatusIcon(bool status) {
  return Row(
    children: [
      Icon(
        Icons.circle,
        size: 12,
        color: status ? Colors.green : Colors.red,
      ),
      const SizedBox(width: 6),
      Text(
        status ? 'Activo' : 'Inactivo',
        style: const TextStyle(color: Colors.white),
      ),
    ],
  );
}


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
