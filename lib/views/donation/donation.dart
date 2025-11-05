import 'package:flutter/material.dart';

// MODELO
import '../../models/donation_m.dart';
// VISTAMODELO
import '../../viewmodels/donation/donation_vm.dart';
// WIDGETS
import '../../widgets/global/table.dart';
import '../../widgets/stock/hoverbutton.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final DonationsViewModel _viewModel = DonationsViewModel();
  final TextEditingController _searchController = TextEditingController();
  List<Donation> _filteredDonations = [];
  List<Donation> _allDonations = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;

  void _searchDonations(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredDonations = [];
      } else {
        _isSearching = true;
        _filteredDonations = _allDonations.where((donation) {
          final lower = query.toLowerCase();
          return donation.titulo.toLowerCase().contains(lower) ||
              donation.autor.toLowerCase().contains(lower) ||
              donation.userEmail.toLowerCase().contains(lower) ||
              donation.lugar.toLowerCase().contains(lower) ||
              (donation.nota?.toLowerCase().contains(lower) ?? false);
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
                  'Donaciones',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      HoverButton(
                        icon: Icons.filter_list,
                        text: 'Filtrar',
                        onPressed: () {},
                        color: Colors.white,
                      ),
                      HoverButton(
                        icon: Icons.download,
                        text: 'Exportar',
                        onPressed: () {},
                        color: Colors.white,
                      ),
                      HoverButton(
                        icon: Icons.upload,
                        text: 'Importar',
                        onPressed: () {},
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BARRA DE BÚSQUEDA
            TextField(
              controller: _searchController,
              onChanged: _searchDonations,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar donaciones (título, autor, usuario, lugar, nota)',
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

            // TABLA DE DONACIONES
            StreamBuilder<List<Donation>>(
              stream: _viewModel.getDonationsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay donaciones registradas',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                _allDonations = snapshot.data!;
                List<Donation> itemsToShow =
                    _isSearching ? _filteredDonations : _allDonations;

                if (_isSearching &&
                    _filteredDonations.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron donaciones con ese criterio de búsqueda',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final startIndex = _currentPage * _itemsPerPage;
                final endIndex =
                    (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
                final donationsPage = itemsToShow.sublist(startIndex, endIndex);

                final columnWidths = <double>[
                  250, // Título
                  250, // Autor
                  80,  // Cantidad
                  150, // Fecha
                  150, // Usuario
                  120, // Lugar
                  150, // Nota
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
                        'Lugar',
                        'Nota'
                      ],
                      rows: donationsPage.map((donation) {
                        return [
                          _buildText(donation.titulo),
                          _buildText(donation.autor),
                          _buildText(donation.cantidad.toString()),
                          _buildText(
                              '${donation.fecha.day}/${donation.fecha.month}/${donation.fecha.year}'),
                          _buildText(donation.userEmail),
                          _buildText(donation.lugar),
                          _buildText(donation.nota ?? ''),
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
