import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
import '../../models/sale_m.dart';

//=========================== VISTAMODELOS ===========================//
import '../../viewmodels/market/sales_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
import '../basic/import/import.dart';
import '../basic/export/download_dialog.dart';
import 'add_sale.dart';
import 'detail_sale.dart';
import 'edit_sale.dart';

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

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  //=========================== CONTROLADORES Y ESTADOS ===========================//
  final SalesViewModel _viewModel = SalesViewModel();
  final ExportViewModel _exportVM = ExportViewModel();
  final TextEditingController _searchController = TextEditingController();

  // STREAM — SUBSCRIPTION PARA EVITAR PARPADEOS
  StreamSubscription? _subscription;

  // LISTAS
  List<Sale> _allSales = [];
  List<Sale> _filteredSales = [];

  // BÚSQUEDA
  bool _isSearching = false;

  // SELECCIÓN
  bool _selectAll = false;
  int _selectedCount = 0;
  final List<Sale> _selectedSales = [];

  // PAGINACIÓN
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  //=========================== INIT ===========================//
  @override
  void initState() {
    super.initState();

    _subscription = _viewModel.getSalesStream().listen((sales) {
      // GUARDAR SELECCIÓN PREVIA
      final prev = {
        for (var s in _allSales.where((s) => s.selected)) s.id: true
      };

      setState(() {
        _allSales = sales;

        // RESTAURAR SELECCIÓN
        for (var s in _allSales) {
          s.selected = prev[s.id] ?? false;
        }

        // RECALCULAR FILTRO SI ESTÁ BUSCANDO
        if (_isSearching) {
          final q = _searchController.text.toLowerCase();
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

  //=========================== SELECCIÓN ===========================//
  void _updateSelectedCount() {
    _selectedSales
      ..clear()
      ..addAll(_allSales.where((s) => s.selected));

    _selectedCount = _selectedSales.length;
    if (mounted) setState(() {});
  }

  //=========================== BÚSQUEDA ===========================//
  void _handleSearchResults(List<Sale> results) {
    setState(() {
      _filteredSales = results;
      _isSearching = _searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  //=========================== DETALLE ===========================//
  void _handleSaleSelected(Sale sale) {
    mostrarDetallVenta(
      context,
      sale,
      onUpdate: (updatedSale) {
        // Refleja cambios en _allSales si la venta fue editada
        setState(() {
          final idx = _allSales.indexWhere((s) => s.id == updatedSale.id);
          if (idx != -1) _allSales[idx] = updatedSale;
        });
      },
    );
  }

  //=========================== CELDAS ===========================//
  Widget _buildClickableCell(Widget child, Sale sale) {
    return GestureDetector(
      onTap: () => _handleSaleSelected(sale),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
                  for (var s in _allSales) {
                    s.selected = _selectAll;
                  }
                  _updateSelectedCount();
                });
              }
            : null,
      ),
      const Text('Título'),
      const Text('Cantidad'),
      const Text('Total'),
      const Text('Fecha'),
      const Text('Lugar'),
      const Text('Acciones'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[
      60,  // checkbox
      280, // título
      100, // cantidad
      120, // total
      120, // fecha
      160, // lugar
      220, // acciones
    ];
    final salesToShow = _isSearching ? _filteredSales : _allSales;
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, salesToShow.length);
    final page = salesToShow.isNotEmpty ? salesToShow.sublist(start, end) : <Sale>[];

    _selectAll = page.isNotEmpty && page.every((s) => s.selected);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== ENCABEZADO ===========================//
            PageHeader(
              title: 'Ventas',
              actions: [
              
                //==================== IMPORTAR ====================//
                SecondaryButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => ImportDialog(
                      entityName: 'Ventas',
                      onImportConfirmed: (List<Map<String, dynamic>> data) async {
                        try {
                          await _viewModel.importSalesFromExcel(data);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Importación finalizada con éxito'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
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
                      totalItems: _viewModel.salesCount,
                      selectedItems: _selectedCount,
                      entityName: 'ventas',
                    );

                    if (option == null) return;

                    if (option == 'all') {
                      final allSales = await _viewModel.getAllSalesAsMap();
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: allSales,
                        fileName: 'ventas_completas',
                        context: context,
                      );
                    } else if (option == 'selected') {
                      if (_selectedSales.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No hay ventas seleccionadas para exportar')),
                        );
                        return;
                      }
                      final selectedData =
                          await _viewModel.getSelectedSalesAsMap(_selectedSales);
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: selectedData,
                        fileName: 'ventas_seleccionadas',
                        context: context,
                      );
                    }
                  },
                ),

                //GENERAR QRS
                SecondaryButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                ),

                //==================== AGREGAR ====================//
                PrimaryButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar ventas',
                  onPressed: () => showSellDialog(context, (_) {}),
                ),
              ],
            ),

            const SizedBox(height: 20),

            //=========================== BÚSQUEDA, FILTRO Y ORDEN ===========================//
            Row(
              children: [
                Expanded(
                  child: Search<Sale>(
                    controller: _searchController,
                    hintText: 'Buscar por título, autor, lugar, etc.',
                    allItems: _allSales,
                    onResults: _handleSearchResults,
                    filter: (s, q) {
                      final x = q.toLowerCase();
                      return s.titulo.toLowerCase().contains(x) ||
                          s.lugar.toLowerCase().contains(x);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                //FILTRAR
                SecondaryButton(
                  icon: Icons.filter_list,
                  text: 'Filtrar',
                  onPressed: () {},
                ),
                
                const SizedBox(width: 12),
                
                //ORDENAR
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //=========================== CONTADOR DE SELECCIONADOS ===========================//
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

                    CustomTable(
                      headers: _buildHeaders(salesToShow.isNotEmpty),
                      rows: page.map((sale) {
                        return [
                          //=========================== CHECKBOX ===========================//
                         TableCheckbox(
                            value: sale.selected,
                            onTap: () {
                              sale.selected = !sale.selected;
                              _updateSelectedCount();
                            },
                          ),

                          //=========================== COLUMNAS DE TEXTO ===========================//
                          _buildClickableCell(TableText(text: sale.titulo), sale),
                          _buildClickableCell(TableText(text: sale.cantidad.toString()), sale),
                          _buildClickableCell(TableText(text: sale.total.toStringAsFixed(2)), sale),
                          _buildClickableCell(TableText(text: '${sale.fecha.day}/${sale.fecha.month}/${sale.fecha.year}'),sale),
                          _buildClickableCell(TableText(text: sale.lugar), sale),
                          TableActions(
                            showCost: false,
                            onEdit: () => showEditSaleDialog(
                              context,
                              sale,
                              onUpdate: (updated) {
                                setState(() {
                                  final idx = _allSales.indexWhere((s) => s.id == updated.id);
                                  if (idx != -1) _allSales[idx] = updated;
                                });
                              },
                            ),
                            onQr: () {},
                            showQR: true,
                            onHistory: () {},
                            onDelete: () {},
                          ),
                        ];
                      }).toList(),
                      width: 1200,
                      columnWidths: columnWidths,
                    ),

                    //=========================== RESULTADOS DE BÚSQUEDA ===========================//
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

                    //=========================== PAGINACIÓN ===========================//
                    if (salesToShow.length > _itemsPerPage)
                      PaginationWidget(
                        currentPage: _currentPage,
                        totalItems: salesToShow.length,
                        itemsPerPage: _itemsPerPage,
                        onPageChanged: (p) =>
                            setState(() => _currentPage = p),
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
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}