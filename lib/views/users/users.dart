import 'package:flutter/material.dart';
// MODELO
import '../../models/user.dart';
// VIEWMODEL
import '../../viewmodels/users/add_user_vm.dart';
// VISTAS
import '../users/add_user.dart';
// WIDGETS
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';

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
                      _buildOutlinedButton(Icons.filter_list, 'Filtrar', () {}),
                      _buildOutlinedButton(Icons.download, 'Exportar', () {}),
                      _buildOutlinedButton(Icons.upload, 'Importar', () {}),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar usuario'),
                        onPressed: () async {
                          await showAddUserDialog(context);
                          await _loadUsuarios(); // Recargar usuarios desde Firebase
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

    final columnWidths = <double>[200, 250, 100];

    return Column(
      children: [
        CustomTable(
          headers: ['Nombre', 'Email', 'Rol'],
          rows: usuariosPage.map((usuario) {
            return [
              _buildText(usuario.name),
              _buildText(usuario.email),
              _buildText(usuario.role.toString().split('.').last),
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
                  onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                ),
                Text('${_currentPage + 1} / ${((itemsToShow.length - 1) / _itemsPerPage).ceil() + 1}'),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: endIndex < itemsToShow.length ? () => setState(() => _currentPage++) : null,
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

  Widget _buildOutlinedButton(IconData icon, String text, VoidCallback onPressed) => Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          borderRadius: BorderRadius.circular(12),
        ),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );

  Widget _buildText(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
      );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
