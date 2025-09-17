import 'package:flutter/material.dart';
// MODELO
import '../../models/acervo_bk.dart';
// VISTAMODELO
import '../../viewmodels/acervo_vm.dart';
// VISTAS
import '../acervo/add_acervo.dart';
// WIDGETS
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';

class AcervoPage extends StatefulWidget {
  final Function(Acervo) onAcervoSelected;

  const AcervoPage({required this.onAcervoSelected, super.key});

  @override
  State<AcervoPage> createState() => _AcervoPageState();
}

class _AcervoPageState extends State<AcervoPage> {
  final AcervoViewModel _viewModel = AcervoViewModel();
  final TextEditingController _searchController = TextEditingController();
  List<Acervo> _filteredAcervos = [];
  List<Acervo> _allAcervos = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;

  void _handleSearchResults(List<Acervo> results) {
    setState(() {
      _filteredAcervos = results;
      _isSearching = results.isNotEmpty || _searchController.text.isNotEmpty;
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
                  'Acervo',
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
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar libro'),
                        onPressed: () {
                          showAddAcervoDialog(context, (newAcervo) =>
                              _viewModel.addAcervo(newAcervo, context));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // TABLA DE ACERVOS
            StreamBuilder<List<Acervo>>(
              stream: _viewModel.getAcervosStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay libros disponibles'));
                }

                _allAcervos = snapshot.data!;
                List<Acervo> itemsToShow = _isSearching ? _filteredAcervos : _allAcervos;

                if (_isSearching && _filteredAcervos.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron libros con ese criterio de búsqueda',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final startIndex = _currentPage * _itemsPerPage;
                final endIndex = (startIndex + _itemsPerPage).clamp(0, itemsToShow.length);
                final acervos = itemsToShow.sublist(startIndex, endIndex);

                final columnWidths = <double>[
                  80,  // Portada
                  180, // Título
                  150, // Subtítulo
                  140, // Autor
                  120, // Editorial
                  120, // Colección
                  60,  // Año
                  120, // ISBN
                  60,  // Edición
                  60,  // Copias
                  80,  // Precio
                  150, // Área
                ];

                return Column(
                  children: [
                    CustomTable(
                      headers: [
                        'Portada','Título','Subtítulo','Autor','Editorial','Colección','Año','ISBN','Edición','Copias','Precio','Área'
                      ],
                      rows: acervos.map((acervo) {
                        return [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              acervo.imagenUrl ?? 'assets/sinportada.png',
                              height: 100,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/sinportada.png',
                                height: 100,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          _buildText(acervo.titulo),
                          _buildText(acervo.subtitulo ?? '-'),
                          _buildText(acervo.autor),
                          _buildText(acervo.editorial),
                          _buildText(acervo.coleccion ?? '-'),
                          _buildText(acervo.anio.toString()),
                          _buildText(acervo.isbn ?? '-'),
                          _buildText(acervo.edicion.toString()),
                          _buildText(acervo.copias.toString()),
                          _buildText('\$${acervo.precio.toStringAsFixed(2)}'),
                          _buildText(acervo.areaConocimiento),
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
                            Text('${_currentPage + 1} / ${((itemsToShow.length - 1) / _itemsPerPage).ceil() + 1}'),
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
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildOutlinedButton(IconData icon, String text, VoidCallback onPressed) => Container(
    decoration: BoxDecoration(
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );

  Widget _buildText(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
