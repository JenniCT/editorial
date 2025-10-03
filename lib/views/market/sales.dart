import 'package:flutter/material.dart';

// MODELO
import '../../models/sale_m.dart';
// VISTAMODELO
import '../../viewmodels/market/sales_vm.dart';
// WIDGETS
import '../../widgets/global/table.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SalesViewModel _viewModel = SalesViewModel();
  final TextEditingController _searchController = TextEditingController();
  List<Sale> _filteredSales = [];
  List<Sale> _allSales = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;

  void _searchSales(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredSales = [];
      } else {
        _isSearching = true;
        _filteredSales = _allSales.where((sale) {
          final lower = query.toLowerCase();
          return sale.titulo.toLowerCase().contains(lower) ||
              sale.autor.toLowerCase().contains(lower) ||
              sale.userEmail.toLowerCase().contains(lower) ||
              sale.lugar.toLowerCase().contains(lower);
        }).toList();
      }
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),

            // TÍTULO Y BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ventas',
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BARRA DE BÚSQUEDA
            TextField(
              controller: _searchController,
              onChanged: _searchSales,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar ventas (título, autor, usuario, lugar)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),

            // TABLA DE VENTAS
            StreamBuilder<List<Sale>>(
              stream: _viewModel.getSalesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay ventas registradas',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                _allSales = snapshot.data!;
                List<Sale> itemsToShow =
                    _isSearching ? _filteredSales : _allSales;

                if (_isSearching &&
                    _filteredSales.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron ventas con ese criterio de búsqueda',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final startIndex = _currentPage * _itemsPerPage;
                final endIndex =
                    (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
                final salesPage = itemsToShow.sublist(startIndex, endIndex);

                final columnWidths = <double>[
                  250, // Título
                  250, // Autor
                  80, // Cantidad
                  150, // Fecha
                  150, // Usuario
                  120, // Lugar
                ];

                return Column(
                  children: [
                    CustomTable(
                      headers: [
                        'Título',
                        'Autor',
                        'Cantidad',
                        'Fecha',
                        'Usuario',
                        'Lugar'
                      ],
                      rows: salesPage.map((sale) {
                        return [
                          _buildText(sale.titulo),
                          _buildText(sale.autor),
                          _buildText(sale.cantidad.toString()),
                          _buildText(
                              '${sale.fecha.day}/${sale.fecha.month}/${sale.fecha.year}'),
                          _buildText(sale.userEmail),
                          _buildText(sale.lugar),
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
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                            ),
                            Text(
                                '${_currentPage + 1} / ${((itemsToShow.length - 1) / _itemsPerPage).ceil() + 1}'),
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
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
          IconData icon, String text, VoidCallback onPressed) =>
      Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );

  Widget _buildText(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white)),
      );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
