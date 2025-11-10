import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

class UsersTable extends StatefulWidget {
  final List<UserModel> allUsuarios;
  final TextEditingController searchController;
  final Function(UserModel) onUserSelected;

  const UsersTable({
    required this.allUsuarios,
    required this.searchController,
    required this.onUserSelected,
    super.key,
  });

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  List<UserModel> _filteredUsuarios = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;
  bool _selectAll = false;
  int _selectedCount = 0;

  void _updateSelectedCount() {
    if (mounted) {
      setState(() {
        _selectedCount = widget.allUsuarios.where((u) => u.selected).length;
      });
    }
  }

  void _handleSearchResults(List<UserModel> results) {
    setState(() {
      _filteredUsuarios = results;
      _isSearching =
          results.isNotEmpty || widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  Widget _buildClickableCell(Widget child, UserModel user) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onUserSelected(user),
        child: SizedBox(width: double.infinity, height: double.infinity, child: child),
      ),
    );
  }

  Widget _buildText(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[50, 200, 250, 120, 120, 120, 100];

    // WIDGET SUPERIOR: BÚSQUEDA Y FILTROS
    Widget buildTopWidget() {
      return Row(
        children: [
          Expanded(
            child: Search<UserModel>(
              controller: widget.searchController,
              allItems: widget.allUsuarios,
              onResults: _handleSearchResults,
              filter: (user, query) {
                final q = query.toLowerCase();
                return user.name.toLowerCase().contains(q) ||
                    user.email.toLowerCase().contains(q) ||
                    user.role.toString().split('.').last.toLowerCase().contains(q);
              },
            ),
          ),
          const SizedBox(width: 12),
          ActionButton(icon: Icons.filter_list, text: 'Filtrar', type: ActionType.secondary, onPressed: () {}),
          const SizedBox(width: 12),
          ActionButton(icon: Icons.sort, text: 'Ordenar', type: ActionType.secondary, onPressed: () {}),
        ],
      );
    }

    // ITEMS A MOSTRAR
    List<UserModel> itemsToShow = _isSearching ? _filteredUsuarios : widget.allUsuarios;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
    final usuariosPage = itemsToShow.sublist(startIndex, endIndex);

    // ACTUALIZA EL SELECT ALL
    _selectAll = usuariosPage.isNotEmpty && usuariosPage.every((u) => u.selected);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Text(
                '$_selectedCount usuario(s) seleccionado(s)',
                style: const TextStyle(
                    color: Color(0xFF1C2532), fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          CustomTable(
            headers: _buildHeaders(true),
            rows: usuariosPage.map((user) {
              return [
                // CHECKBOX
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    key: ValueKey(user.selected),
                    icon: Icon(
                      user.selected
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank_outlined,
                      color: user.selected ? Colors.green : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        user.selected = !user.selected;
                      });
                      _updateSelectedCount();
                    },
                  ),
                ),
                _buildClickableCell(_buildText(user.name), user),
                _buildClickableCell(_buildText(user.email), user),
                _buildClickableCell(_buildText(user.role.toString().split('.').last), user),
                _buildClickableCell(_buildText(DateFormat('dd/MM/yyyy').format(user.createAt)), user),
                _buildClickableCell(
                    _buildText(user.expiresAt != null
                        ? DateFormat('dd/MM/yyyy').format(user.expiresAt!)
                        : 'No asignado'),
                    user),
                _buildClickableCell(_buildText(user.status ? 'Activo' : 'Inactivo'), user),
              ];
            }).toList(),
            columnWidths: columnWidths,
            width: 1200,
            topWidget: buildTopWidget(),
          ),

          // PAGINACIÓN
          if (itemsToShow.length > _itemsPerPage)
            PaginationWidget(
              currentPage: _currentPage,
              totalItems: itemsToShow.length,
              itemsPerPage: _itemsPerPage,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),

          // RESULTADOS DE BÚSQUEDA
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mostrando ${itemsToShow.length} resultado(s)',
                style: const TextStyle(color: Color(0xFF1C2532), fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildHeaders(bool enableSelectAll) {
    return [
      IconButton(
        icon: Icon(_selectAll ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
            color: Colors.white),
        onPressed: enableSelectAll
            ? () {
                setState(() {
                  _selectAll = !_selectAll;
                  for (var user in widget.allUsuarios) user.selected = _selectAll;
                });
                _updateSelectedCount();
              }
            : null,
      ),
      const Text('Nombre', style: TextStyle(color: Colors.white)),
      const Text('Email', style: TextStyle(color: Colors.white)),
      const Text('Rol', style: TextStyle(color: Colors.white)),
      const Text('Creación', style: TextStyle(color: Colors.white)),
      const Text('Expiración', style: TextStyle(color: Colors.white)),
      const Text('Estado', style: TextStyle(color: Colors.white)),
    ];
  }
}
