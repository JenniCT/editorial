import 'dart:async';
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

  final void Function(int selectedCount)? onSelectionChanged;

  const SalesTable({
    required this.viewModel,
    required this.searchController,
    required this.onSaleSelected,
    this.onSelectionChanged,
    super.key,
  });

  @override
  State<SalesTable> createState() => SalesTableState();
}

class SalesTableState extends State<SalesTable> {
  //=========================== STREAM ===========================//
  StreamSubscription? _subscription;

  //=========================== LISTAS ===========================//
  List<Sale> _allSales = [];
  List<Sale> _filteredSales = [];

  //=========================== PAGINACIÓN ===========================//
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  //=========================== ESTADOS ===========================//
  bool _isSearching = false;
  bool _selectAll = false;
  int _selectedCount = 0;

  final List<Sale> _selectedSales = [];
  List<Sale> get selectedSales => _selectedSales;

  //=========================== INIT ===========================//
  @override
  void initState() {
    super.initState();

    _subscription = widget.viewModel.getSalesStream().listen((sales) {
      // Guardar selección previa
      final prev = {for (var s in _allSales.where((s) => s.selected)) s.id: true};

      setState(() {
        _allSales = sales;

        // Restaurar selección
        for (var s in _allSales) {
          s.selected = prev[s.id] ?? false;
        }

        // Mantener filtro si se está buscando
        if (_isSearching) {
          final q = widget.searchController.text.toLowerCase();

          _filteredSales = _allSales.where((s) {
            return s.titulo.toLowerCase().contains(q) ||
                s.userEmail.toLowerCase().contains(q) ||
                s.lugar.toLowerCase().contains(q);
          }).toList();
        }

        _updateSelectedCount();
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  //=========================== SELECCIÓN ===========================//
  void _updateSelectedCount() {
    _selectedSales
      ..clear()
      ..addAll(_allSales.where((s) => s.selected));

    _selectedCount = _selectedSales.length;

    widget.onSelectionChanged?.call(_selectedCount);

    if (mounted) setState(() {});
  }

  //=========================== BÚSQUEDA ===========================//
  void _handleSearchResults(List<Sale> results) {
    setState(() {
      _filteredSales = results;
      _isSearching = widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  //=========================== CELDAS ===========================//
  Widget _buildClickableCell(Widget child, Sale sale) {
    return GestureDetector(
      onTap: () => widget.onSaleSelected(sale),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(width: double.infinity, child: child),
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
                  for (var s in _allSales) {
                    s.selected = _selectAll;
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

  //=========================== BUILD ===========================//
  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[50, 320, 150, 150, 150, 150, 200];

    //=========================== PANEL SUPERIOR ===========================//
    Widget buildTopWidget() {
      return Row(
        children: [
          Expanded(
            child: Search<Sale>(
              controller: widget.searchController,
              allItems: _allSales,
              onResults: _handleSearchResults,
              filter: (s, q) {
                final x = q.toLowerCase();
                return s.titulo.toLowerCase().contains(x) ||
                    s.userEmail.toLowerCase().contains(x) ||
                    s.lugar.toLowerCase().contains(x);
              },
            ),
          ),
          const SizedBox(width: 12),
          ActionButton(
            icon: Icons.filter_list,
            text: 'Filtrar',
            type: ActionType.secondary,
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          ActionButton(
            icon: Icons.sort,
            text: 'Ordenar',
            type: ActionType.secondary,
            onPressed: () {},
          ),
        ],
      );
    }

    final salesToShow = _isSearching ? _filteredSales : _allSales;

    if (salesToShow.isEmpty) {
      return CustomTable(
        headers: _buildHeaders(false),
        rows: const [],
        width: 1200,
        columnWidths: columnWidths,
        topWidget: buildTopWidget(),
      );
    }

    //=========================== PAGINACIÓN ===========================//
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, salesToShow.length);

    final page = salesToShow.sublist(start, end);

    _selectAll = page.isNotEmpty && page.every((s) => s.selected);

    return SingleChildScrollView(
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
                ),
              ),
            ),

          //=========================== TABLA ===========================//
          CustomTable(
            headers: _buildHeaders(true),
            rows: page.map((sale) {
              return [
                IconButton(
                  icon: Icon(
                    sale.selected
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank_outlined,
                    color:
                        sale.selected ? const Color(0xFF1C2532) : Colors.white,
                  ),
                  onPressed: () {
                    sale.selected = !sale.selected;
                    _updateSelectedCount();
                  },
                ),
                _buildClickableCell(_buildText(sale.titulo), sale),
                _buildClickableCell(
                    _buildText(sale.cantidad.toString()), sale),
                _buildClickableCell(
                    _buildText(sale.total.toStringAsFixed(2)), sale),
                _buildClickableCell(
                  _buildText(
                      '${sale.fecha.day}/${sale.fecha.month}/${sale.fecha.year}'),
                  sale,
                ),
                _buildClickableCell(_buildText(sale.lugar), sale),
                _buildClickableCell(_buildText(sale.userEmail), sale),
              ];
            }).toList(),
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          ),

          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mostrando ${salesToShow.length} resultado(s)',
                style: const TextStyle(
                  color: Color(0xFF1C2532),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          if (salesToShow.length > _itemsPerPage)
            PaginationWidget(
              currentPage: _currentPage,
              totalItems: salesToShow.length,
              itemsPerPage: _itemsPerPage,
              onPageChanged: (page) => setState(() {
                _currentPage = page;
              }),
            ),
        ],
      ),
    );
  }
}
