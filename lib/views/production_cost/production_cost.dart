import 'package:flutter/material.dart';
import '../../models/production_cost.dart';
import '../../viewmodels/prodution_cost/production_cost_vm.dart';
import '../../widgets/global/table.dart';
import '../../widgets/global/background.dart';
import 'add_production_cost.dart';

class CostosProduccionPage extends StatefulWidget {
  final String idBook;
  const CostosProduccionPage({super.key, required this.idBook});

  @override
  State<CostosProduccionPage> createState() => _CostosProduccionPageState();
}

class _CostosProduccionPageState extends State<CostosProduccionPage> {
  final CostosProduccionViewModel _viewModel = CostosProduccionViewModel();
  List<CostosProduccion> _allCostos = [];
  List<CostosProduccion> _filteredCostos = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadCostos();
  }

  void _loadCostos() {
    _viewModel.getCostosPorLibro(widget.idBook).listen((data) {
      if (mounted) {
        setState(() {
          _allCostos = data;
        });
      }
    });
  }

  void _searchCostos(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredCostos = [];
      } else {
        _isSearching = true;
        final lower = query.toLowerCase();
        _filteredCostos = _allCostos.where((c) {
          return c.registradoPor.toLowerCase().contains(lower) ||
              c.papelBon.toString().contains(lower) ||
              c.couchel.toString().contains(lower) ||
              c.manoObra.toString().contains(lower);
        }).toList();
      }
      _currentPage = 0;
    });
  }

  void _openAddCostDialog() async {
    showAddProductionCostDialog(context, widget.idBook, (newCost) {
      setState(() {
        _allCostos.add(newCost);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Costos de Producción",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: Stack(
        children: [
          Background(),
          Column(
            children: [
              // BARRA FIJA DE BÚSQUEDA
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: _searchCostos,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar costos (usuario, valores)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        Flexible(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar costo'),
                                onPressed: _openAddCostDialog,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🧾 TABLA SCROLLEABLE
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCostosTable(),
                ),
              ),
            ],
          ),
        ],
      ),

    );
  }

  Widget _buildCostosTable() {
    final itemsToShow = _isSearching ? _filteredCostos : _allCostos;

    if (itemsToShow.isEmpty) {
      return const Center(
          child: Text(
        'No hay costos disponibles',
        style: TextStyle(color: Colors.white),
      ));
    }

    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
    final pageData = itemsToShow.sublist(startIndex, endIndex);

    final columnWidths = <double>[
      120,
      120,
      120,
      120,
      120,
      120,
      120,
      120,
      120,
      120,
      150,
    ];

    return Column(
      children: [
        CustomTable(
          headers: [
            "Papel Bon",
            "Couchel",
            "Mano de Obra",
            "Material",
            "Derechos de Autor",
            "ISBN",
            "Servicios",
            "Costo Extra 1",
            "Costo Extra 2",
            "Costo Extra 3",
            "Fecha",
          ],
          rows: pageData.map((c) {
            return [
              _buildText(c.papelBon.toStringAsFixed(2)),
              _buildText(c.couchel.toStringAsFixed(2)),
              _buildText(c.manoObra.toStringAsFixed(2)),
              _buildText(c.material.toStringAsFixed(2)),
              _buildText(c.derechosAutor.toStringAsFixed(2)),
              _buildText(c.isbn.toStringAsFixed(2)),
              _buildText(c.servicios.toStringAsFixed(2)),
              _buildText(c.costoExtra1.toStringAsFixed(2)),
              _buildText(c.costoExtra2.toStringAsFixed(2)),
              _buildText(c.costoExtra3.toStringAsFixed(2)),
              _buildText(
                  "${c.fechaRegistro.day}/${c.fechaRegistro.month}/${c.fechaRegistro.year}"),
            ];
          }).toList(),
          columnWidths: columnWidths,
        ),
        const SizedBox(height: 20),
        // PAGINACIÓN
        if (itemsToShow.length > _itemsPerPage)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text(
                '${_currentPage + 1} / ${((itemsToShow.length - 1) / _itemsPerPage).ceil() + 1}',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: endIndex < itemsToShow.length
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
      ],
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
