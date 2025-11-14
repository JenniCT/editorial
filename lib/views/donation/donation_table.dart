import 'package:flutter/material.dart';
import '../../viewmodels/donation/donation_vm.dart';
import '../../models/donation_m.dart';
import '../../widgets/global/search.dart';
import '../../widgets/modules/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

class DonationsTable extends StatefulWidget {
  final DonationsViewModel viewModel;
  final TextEditingController searchController;

  const DonationsTable({
    required this.viewModel,
    required this.searchController,
    super.key,
  });

  @override
  State<DonationsTable> createState() => _DonationsTableState();
}

class _DonationsTableState extends State<DonationsTable> {
  final List<Donation> _allDonations = [];
  List<Donation> _filteredDonations = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;

  bool _selectAll = false;
  int _selectedCount = 0;

  void _updateSelectedCount() {
    _selectedCount = _allDonations.where((d) => d.selected).length;
    _selectAll = _allDonations.isNotEmpty && _allDonations.every((d) => d.selected);
  }

  void _handleSearchResults(List<Donation> results) {
    setState(() {
      _filteredDonations = results;
      _isSearching = results.isNotEmpty || widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  Widget _buildText(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      );

  Widget _buildTopWidget() {
    return Row(
      children: [
        Expanded(
          child: Search<Donation>(
            controller: widget.searchController,
            allItems: _allDonations,
            onResults: _handleSearchResults,
            filter: (don, query) {
              final q = query.toLowerCase();
              return don.titulo.toLowerCase().contains(q) ||
                  don.autor.toLowerCase().contains(q) ||
                  don.userEmail.toLowerCase().contains(q) ||
                  don.lugar.toLowerCase().contains(q) ||
                  (don.nota?.toLowerCase().contains(q) ?? false);
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
                  for (var d in _allDonations) {
                    d.selected = _selectAll;
                  }
                  _updateSelectedCount();
                });
              }
            : null,
      ),
      const Text('Título', style: TextStyle(color: Colors.white)),
      const Text('Autor', style: TextStyle(color: Colors.white)),
      const Text('Cantidad', style: TextStyle(color: Colors.white)),
      const Text('Fecha', style: TextStyle(color: Colors.white)),
      const Text('Usuario', style: TextStyle(color: Colors.white)),
      const Text('Lugar', style: TextStyle(color: Colors.white)),
      const Text('Nota', style: TextStyle(color: Colors.white)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[50, 250, 180, 80, 120, 130, 150, 200];

    return StreamBuilder<List<Donation>>(
      stream: widget.viewModel.getDonationsStream(),
      builder: (context, snapshot) {
        // Agregar solo nuevos items, mantener los existentes para conservar selección
        if (snapshot.hasData) {
          for (var newDonation in snapshot.data!) {
            if (!_allDonations.any((d) => d.id == newDonation.id)) {
              _allDonations.add(newDonation);
            }
          }
        }

        List<Donation> itemsToShow = _isSearching ? _filteredDonations : _allDonations;

        if (itemsToShow.isEmpty) {
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: _buildTopWidget(),
          );
        }

        final totalPages = (itemsToShow.length / _itemsPerPage).ceil();
        if (_currentPage >= totalPages) _currentPage = totalPages - 1;

        final startIndex = (_currentPage * _itemsPerPage).clamp(0, itemsToShow.length);
        final endIndex = ((startIndex + _itemsPerPage)).clamp(startIndex, itemsToShow.length);
        final donationsPage = itemsToShow.sublist(startIndex, endIndex);

        _updateSelectedCount();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    '$_selectedCount donación(es) seleccionadas',
                    style: const TextStyle(color: Color(0xFF1C2532), fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              CustomTable(
                headers: _buildHeaders(true),
                rows: donationsPage.map((donation) {
                  return [
                    IconButton(
                      icon: Icon(
                        donation.selected ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                        color: donation.selected ? const Color(0xFF1C2532) : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          donation.selected = !donation.selected;
                          _updateSelectedCount();
                        });
                      },
                    ),
                    _buildText(donation.titulo),
                    _buildText(donation.autor),
                    _buildText(donation.cantidad.toString()),
                    _buildText('${donation.fecha.day}/${donation.fecha.month}/${donation.fecha.year}'),
                    _buildText(donation.userEmail),
                    _buildText(donation.lugar),
                    _buildText(donation.nota ?? ''),
                  ];
                }).toList(),
                columnWidths: columnWidths,
                width: 1200,
                topWidget: _buildTopWidget(),
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
