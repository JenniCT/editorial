import 'package:flutter/material.dart';
import '../../viewmodels/market/sales_vm.dart';
import '../../models/sale_m.dart';

//=========================== IMPORTACIÓN DE WIDGETS ===========================//
// IMPORTA COMPONENTES REUTILIZABLES DE UI, COMO TABLAS, BUSQUEDAS Y BOTONES
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

class SalesTable extends StatefulWidget {
  final SalesViewModel viewModel;
  final TextEditingController searchController;

  const SalesTable({
    required this.viewModel,
    required this.searchController,
    super.key,
  });

  @override
  State<SalesTable> createState() => _SalesTableState();
}

class _SalesTableState extends State<SalesTable> {
  List<Sale> _allSales = [];
  List<Sale> _filteredSales = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;
  bool _selectAll = false;
  int _selectedCount = 0;

  void _updateSelectedCount() {
    _selectedCount = _allSales.where((s) => s.selected).length;
    _selectAll = _allSales.isNotEmpty && _allSales.every((s) => s.selected);
  }

  void _handleSearchResults(List<Sale> results) {
    setState(() {
      _filteredSales = results;
      _isSearching = results.isNotEmpty || widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  Widget _buildText(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white)),
      );

  Widget _buildTopWidget() {
    return Row(
      children: [
        Expanded(
          child: Search<Sale>(
            controller: widget.searchController,
            allItems: _allSales,
            onResults: _handleSearchResults,
            filter: (sale, query) {
              final q = query.toLowerCase();
              return sale.titulo.toLowerCase().contains(q) ||
                  sale.autor.toLowerCase().contains(q) ||
                  sale.userEmail.toLowerCase().contains(q) ||
                  sale.lugar.toLowerCase().contains(q);
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

  List<Widget> _buildHeaders(bool enableSelectAll) {
    return [
      IconButton(
        icon: Icon(
          _selectAll ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
          color: Colors.white,
        ),
        onPressed: enableSelectAll
            ? () {
                setState(() {
                  _selectAll = !_selectAll;
                  final previousSelections = {for (var s in _allSales.where((s) => s.selected)) s.id: true};
                  for (var sale in _allSales) {
                    if (previousSelections.containsKey(sale.id)) sale.selected = true;
                  }

                });
              }
            : null,
      ),
      const Text('Título', style: TextStyle(color: Colors.white)),
      const Text('Cantidad', style: TextStyle(color: Colors.white)),
      const Text('Total', style: TextStyle(color: Colors.white)),
      const Text('Fecha', style: TextStyle(color: Colors.white)),
      const Text('Lugar', style: TextStyle(color: Colors.white)),
      const Text('Usuario', style: TextStyle(color: Colors.white)), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[50, 320, 150, 150, 150, 150,200];

    return StreamBuilder<List<Sale>>(
      stream: widget.viewModel.getSalesStream(),
      builder: (context, snapshot) {
        _allSales = snapshot.data ?? [];

        // Mantener selección previa
        final previousSelections = {for (var s in _allSales.where((s) => s.selected)) s.id: true};
        for (var sale in _allSales) {
          if (previousSelections.containsKey(sale.id)) sale.selected = true;
        }

        List<Sale> itemsToShow = _isSearching ? _filteredSales : _allSales;

        if (itemsToShow.isEmpty) {
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: _buildTopWidget(),
          );
        }

        // Paginación segura
        final totalPages = (itemsToShow.length / _itemsPerPage).ceil();
        if (_currentPage >= totalPages) _currentPage = totalPages - 1;

        final startIndex = (_currentPage * _itemsPerPage).clamp(0, itemsToShow.length);
        final endIndex = ((_currentPage * _itemsPerPage) + _itemsPerPage).clamp(startIndex, itemsToShow.length);
        final salesPage = itemsToShow.sublist(startIndex, endIndex);

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    '$_selectedCount venta(s) seleccionadas',
                    style: const TextStyle(color: Color(0xFF1C2532), fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              CustomTable(
                headers: _buildHeaders(true),
                rows: salesPage.map((sale) {
                  return [
                    // Checkbox
                    IconButton(
                      icon: Icon(
                        sale.selected ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                        color: sale.selected ? const Color(0xFF1C2532) : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          sale.selected = !sale.selected;
                          _updateSelectedCount();
                        });
                      },
                    ),
                    _buildText(sale.titulo),
                    _buildText(sale.cantidad.toString()),
                    _buildText(sale.total.toStringAsFixed(2)),
                    _buildText('${sale.fecha.day}/${sale.fecha.month}/${sale.fecha.year}'),
                    _buildText(sale.lugar),
                    _buildText(sale.userEmail),
                  ];
                }).toList(),
                columnWidths: columnWidths,
                width: 1200,
                topWidget: _buildTopWidget(),
              ),

              // Paginación
              if (itemsToShow.length > _itemsPerPage)
                PaginationWidget(
                  currentPage: _currentPage,
                  totalItems: itemsToShow.length,
                  itemsPerPage: _itemsPerPage,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
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
          ),
        );
      },
    );
  }
}
