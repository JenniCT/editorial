import 'package:flutter/material.dart';
import '../../viewmodels/market/sales_vm.dart';
import '../../models/sale_m.dart';
import '../../widgets/global/search.dart';
import '../../widgets/modules/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

class SalesTable extends StatefulWidget {
  final SalesViewModel viewModel;
  final TextEditingController searchController;
  final Function(Sale) onSaleSelected;

  const SalesTable({
    required this.viewModel,
    required this.searchController,
    required this.onSaleSelected,
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
    if (mounted) {
      setState(() {
        _selectedCount = _allSales.where((s) => s.selected).length;
      });
    }
  }

  void _handleSearchResults(List<Sale> results) {
    setState(() {
      _filteredSales = results;
      _isSearching = results.isNotEmpty || widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  Widget _buildClickableCell(Widget child, Sale sale) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onSaleSelected(sale),
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
                  for (var sale in _allSales) {
                    sale.selected = _selectAll;
                  }
                  _updateSelectedCount();
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
    final columnWidths = <double>[50, 320, 150, 150, 150, 150, 200];

    Widget buildTopWidget() {
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

    return StreamBuilder<List<Sale>>(
      stream: widget.viewModel.getSalesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          );
        }

        final previousSelections = {for (var s in _allSales.where((s) => s.selected)) s.id: true};
        _allSales = snapshot.data ?? [];
        for (var sale in _allSales) {
          if (previousSelections.containsKey(sale.id)) sale.selected = true;
        }

        List<Sale> itemsToShow = _isSearching ? _filteredSales : _allSales;

        if (_allSales.isEmpty || (_isSearching && itemsToShow.isEmpty)) {
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          );
        }

        final startIndex = _currentPage * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
        final salesPage = itemsToShow.sublist(startIndex, endIndex);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSelectedCount();
        });

        _selectAll = salesPage.isNotEmpty && salesPage.every((s) => s.selected);

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
                    style: const TextStyle(
                        color: Color(0xFF1C2532),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto'),
                  ),
                ),
              CustomTable(
                headers: _buildHeaders(true),
                rows: salesPage.map((sale) {
                  return [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        key: ValueKey(sale.selected),
                        icon: Icon(
                          sale.selected ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                          color: sale.selected ? const Color(0xFF1C2532) : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            sale.selected = !sale.selected;
                          });
                          _updateSelectedCount();
                        },
                      ),
                    ),
                    _buildClickableCell(_buildText(sale.titulo), sale),
                    _buildClickableCell(_buildText(sale.cantidad.toString()), sale),
                    _buildClickableCell(_buildText(sale.total.toStringAsFixed(2)), sale),
                    _buildClickableCell(_buildText('${sale.fecha.day}/${sale.fecha.month}/${sale.fecha.year}'), sale),
                    _buildClickableCell(_buildText(sale.lugar), sale),
                    _buildClickableCell(_buildText(sale.userEmail), sale),
                  ];
                }).toList(),
                columnWidths: columnWidths,
                width: 1200,
                topWidget: buildTopWidget(),
              ),
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Mostrando ${itemsToShow.length} resultado(s)',
                    style: const TextStyle(color: Color(0xFF1C2532), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Roboto'),
                  ),
                ),
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
            ],
          ),
        );
      },
    );
  }
}
