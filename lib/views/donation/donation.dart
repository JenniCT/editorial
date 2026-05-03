import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
import '../../models/donation_m.dart';

//=========================== VISTAMODELOS ===========================//
import '../../viewmodels/donation/donation_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
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

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  //=========================== CONTROLADORES Y ESTADOS ===========================//
  final DonationsViewModel _viewModel = DonationsViewModel();
  final ExportViewModel _exportVM = ExportViewModel();
  final TextEditingController _searchController = TextEditingController();

  // LISTAS
  final List<Donation> _allDonations = [];
  List<Donation> _filteredDonations = [];

  // BÚSQUEDA
  bool _isSearching = false;

  // SELECCIÓN
  bool _selectAll = false;
  int _selectedCount = 0;

  // PAGINACIÓN
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  //=========================== SELECCIÓN ===========================//
  List<Donation> get _selectedDonations =>
      _allDonations.where((d) => d.selected).toList();

  void _updateSelectedCount() {
    _selectedCount = _selectedDonations.length;
    _selectAll =
        _allDonations.isNotEmpty && _allDonations.every((d) => d.selected);
  }

  //=========================== BÚSQUEDA ===========================//
  void _handleSearchResults(List<Donation> results) {
    setState(() {
      _filteredDonations = results;
      _isSearching = _searchController.text.isNotEmpty;
      _currentPage = 0;
    });
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
                  for (var d in _allDonations) {
                    d.selected = _selectAll;
                  }
                  _updateSelectedCount();
                });
              }
            : null,
      ),
      const Text('Título'),
      const Text('Autor'),
      const Text('Cantidad'),
      const Text('Fecha'),
      const Text('Usuario'),
      const Text('Lugar'),
      const Text('Nota'),
      const Text('Acciones'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[
      60,  // checkbox
      240, // título
      180, // autor
      90,  // cantidad
      120, // fecha
      180, // usuario
      160, // lugar
      180, // nota
      220, // acciones
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== ENCABEZADO ===========================//
            PageHeader(
              title: 'Donaciones',
              actions: [
                
                // EXPORTAR
                SecondaryButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () async {
                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: _viewModel.donationsCount,
                      selectedItems: _selectedCount,
                      entityName: 'donaciones',
                    );

                    if (option == null) return;

                    if (option == 'all') {
                      final allData = _viewModel.getAllDonationsAsMap();
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: allData,
                        fileName: 'donaciones_completas',
                        context: context,
                      );
                    } else if (option == 'selected') {
                      if (_selectedDonations.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No hay donaciones seleccionadas')),
                        );
                        return;
                      }
                      final data =
                          _viewModel.getSelectedDonationsAsMap(_selectedDonations);
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: data,
                        fileName: 'donaciones_seleccionadas',
                        context: context,
                      );
                    }
                  },
                ),
                
                // GENERAR QRs
                SecondaryButton(
                  icon: CupertinoIcons.qrcode_viewfinder,
                  text: 'Generar QRs',
                  onPressed: () {},
                ),
                
                // AGREGAR DONACIÓN
                PrimaryButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar donación',
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            //=========================== STREAM + TABLA ===========================//
            Expanded(
              child: StreamBuilder<List<Donation>>(
                stream: _viewModel.getDonationsStream(),
                builder: (context, snapshot) {
                  // AGREGA SOLO DONACIONES NUEVAS, PRESERVANDO SELECCIÓN
                  if (snapshot.hasData) {
                    for (var newDonation in snapshot.data!) {
                      if (!_allDonations.any((d) => d.id == newDonation.id)) {
                        _allDonations.add(newDonation);
                      }
                    }
                  }

                  final List<Donation> itemsToShow =
                      _isSearching ? _filteredDonations : _allDonations;

                  // PAGINACIÓN
                  final totalPages =
                      (itemsToShow.length / _itemsPerPage).ceil();
                  if (_currentPage >= totalPages && totalPages > 0) {
                    _currentPage = totalPages - 1;
                  }

                  final startIndex =
                      (_currentPage * _itemsPerPage).clamp(0, itemsToShow.length);
                  final endIndex =
                      (startIndex + _itemsPerPage).clamp(startIndex, itemsToShow.length);
                  final donationsPage = itemsToShow.isNotEmpty
                      ? itemsToShow.sublist(startIndex, endIndex)
                      : <Donation>[];

                  _updateSelectedCount();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //=========================== BÚSQUEDA, FILTRO Y ORDEN ===========================//
                      Row(
                        children: [
                          Expanded(
                            child: Search<Donation>(
                              controller: _searchController,
                              hintText: 'Buscar por título, autor, email del usuario, lugar, etc.',
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
                          
                          // FILTRAR
                          SecondaryButton(
                            icon: Icons.filter_list,
                            text: 'Filtrar',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                          
                          // ORDENAR
                          SecondaryButton(
                            icon: Icons.sort,
                            text: 'Ordenar',
                            onPressed: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      //=========================== CONTADOR DE SELECCIONADOS ===========================//
                      if (_selectedCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 8),
                          child: Text(
                            '$_selectedCount donación(es) seleccionadas',
                            style: const TextStyle(
                              color: Color(0xFF1C2532),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                      //=========================== TABLA ===========================//
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTable(
                                headers: _buildHeaders(itemsToShow.isNotEmpty),
                                rows: donationsPage.map((donation) {
                                  return [
                                    //=========================== CHECKBOX ===========================//
                                    TableCheckbox(
                                      value: donation.selected,
                                      onTap: () {
                                        setState(() {
                                          donation.selected = !donation.selected;
                                          _updateSelectedCount();
                                        });
                                      },
                                    ),

                                    //=========================== COLUMNAS DE TEXTO ===========================//
                                    TableText(text: donation.titulo),
                                    TableText(text: donation.autor),
                                    TableText(text: donation.cantidad.toString()),
                                    TableText(text: '${donation.fecha.day}/${donation.fecha.month}/${donation.fecha.year}'),
                                    TableText(text: donation.userEmail),
                                    TableText(text: donation.lugar),
                                    TableText(text: donation.nota ?? ''),
                                    TableActions(
                                      showCost: false,
                                      onEdit: () {},
                                      showQR: true,
                                      onHistory: () {},
                                      onDelete: () {},
                                    ),
                                  ];
                                }).toList(),
                                columnWidths: columnWidths,
                                width: 1200,
                              ),

                              //=========================== RESULTADOS DE BÚSQUEDA ===========================//
                              if (_isSearching)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Mostrando ${itemsToShow.length} resultado(s)',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
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
                            ],
                          ),
                        ),
                      ),
                    ],
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