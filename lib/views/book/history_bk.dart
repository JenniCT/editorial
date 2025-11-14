import 'package:flutter/material.dart';
import '../../viewmodels/book/book_vm.dart';
import '../../models/history_bk.dart';
import '../../widgets/table/table.dart';


class HistorialPage extends StatefulWidget {
  final String idBook; 
  const HistorialPage({super.key, required this.idBook});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final BookViewModel _viewModel = BookViewModel();
  final TextEditingController _searchController = TextEditingController();
  List<Historial> _filteredHistorial = [];
  List<Historial> _allHistorial = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;

  void _searchHistorial(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredHistorial = [];
      } else {
        _isSearching = true;
        _filteredHistorial = _allHistorial.where((h) {
          final lower = query.toLowerCase();
          final cambiosStr = h.cambios.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ')
              .toLowerCase();

          return h.editadoPor.toLowerCase().contains(lower) ||
              h.accion.toLowerCase().contains(lower) ||
              cambiosStr.contains(lower);
        }).toList();
      }
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Historial de Cambios",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: Stack(  
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: kToolbarHeight + 10),

                // BARRA DE BÚSQUEDA
                TextField(
                  controller: _searchController,
                  onChanged: _searchHistorial,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar historial (usuario, acción, cambios)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // TABLA DE HISTORIAL
                StreamBuilder<List<Historial>>(
                  stream: _viewModel.getHistorialPorLibro(widget.idBook),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay historial de cambios',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    _allHistorial = snapshot.data!;
                    List<Historial> itemsToShow =
                        _isSearching ? _filteredHistorial : _allHistorial;

                    if (_isSearching &&
                        _filteredHistorial.isEmpty &&
                        _searchController.text.isNotEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron registros con ese criterio de búsqueda',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final startIndex = _currentPage * _itemsPerPage;
                    final endIndex =
                        (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
                    final historialPage =
                        itemsToShow.sublist(startIndex, endIndex);

                    final columnWidths = <double>[
                      150, // Usuario
                      150, // Fecha
                      120, // Acción
                      500, // Cambios
                    ];

                    return Column(
                      children: [
                        CustomTable(
                          headers: ['Usuario', 'Fecha', 'Acción', 'Cambios'],
                          rows: historialPage.map((h) {
                            return [
                              _buildText(h.editadoPor),
                              _buildText(
                                  '${h.fechaEdicion.day}/${h.fechaEdicion.month}/${h.fechaEdicion.year}'),
                              _buildText(h.accion),
                              _buildText(
                                h.cambios.entries
                                    .map((e) => '${e.key}: ${e.value}')
                                    .join('\n'),
                              ),
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
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
