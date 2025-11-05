import 'package:flutter/material.dart';
// MODELO
import '../../models/book_m.dart';
// VISTAMODELO
import '../../viewmodels/acervo/acervo_vm.dart';
// VISTAS
import '../acervo/add_acervo.dart';
import '../book/details_bk.dart';
// WIDGETS
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';
import '../../widgets/stock/hoverbutton.dart';

class AcervoPage extends StatefulWidget {
  final Function(Book) onAcervoSelected;

  const AcervoPage({required this.onAcervoSelected, super.key});

  @override
  State<AcervoPage> createState() => _AcervoPageState();
}

class _AcervoPageState extends State<AcervoPage> {
  final AcervoViewModel _viewModel = AcervoViewModel();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];
  List<Book> _allBooks = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;
  // VARIABLE PARA EL LIBRO SELCCIONADO Y ESTADO DE DETALLE
  Book? _selectedBook;
  bool _showingDetail = false;

  // MÉTODO PARA SELECCIONAR UN LIBRO
  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }

  // MÉTODO PARA CREAR UNA CELDA CLICKEABLE EN LA TABLA
  Widget _buildClickableCell(Widget child, Book book) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleBookSelection(book),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //MOSTRAR DETALLE DEL LIBRO SI SE SELECCIONA
    if (_showingDetail && _selectedBook != null) {
      return DetalleLibroPage(
        book: _selectedBook!,
        onBack: () => setState(() => _showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARRA DE BÚSQUEDA
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Search<Book>(
                    controller: _searchController,
                    allItems: _allBooks,
                    onResults: (results) {
                      setState(() {
                        _filteredBooks = results;
                        _isSearching =
                            results.isNotEmpty ||
                            _searchController.text.isNotEmpty;
                        _currentPage = 0;
                      });
                    },
                    filter: (book, query) {
                      return book.tituloLower.contains(query) ||
                          book.autorLower.contains(query) ||
                          (book.subtitulo ?? '').toLowerCase().contains(
                            query,
                          ) ||
                          book.editorialLower.contains(query) ||
                          (book.coleccion ?? '').toLowerCase().contains(
                            query,
                          ) ||
                          (book.isbn ?? '').toLowerCase().contains(query) ||
                          book.anio.toString().contains(query) ||
                          book.edicion.toString().contains(query) ||
                          book.copias.toString().contains(query) ||
                          book.areaLower.contains(query);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

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
                      HoverButton(
                        icon: Icons.filter_list,
                        text:  'Filtrar',
                        onPressed: () {},
                        color: Colors.white,),
                      HoverButton(
                        icon:  Icons.download,
                        text:  'Exportar',
                        onPressed: () {},
                        color: Colors.white,
                      ),
                      HoverButton(
                        icon: Icons.upload,
                        text:  'Importar',
                        onPressed: () {},
                        color: Colors.white,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar libro'),
                        onPressed: () {
                          showAddAcervoDialog(
                            context,
                            (newBook) => _viewModel.addAcervo(newBook, context),
                          );
                        },
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
            const SizedBox(height: 20),

            // TABLA DE ACERVOS
            StreamBuilder<List<Book>>(
              stream: _viewModel.getAcervosStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay libros disponibles'));
                }

                _allBooks = snapshot.data!;
                List<Book> itemsToShow = _isSearching
                    ? _filteredBooks
                    : _allBooks;

                if (_isSearching &&
                    _filteredBooks.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron libros con ese criterio de búsqueda',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final startIndex = _currentPage * _itemsPerPage;
                final endIndex = (startIndex + _itemsPerPage).clamp(
                  0,
                  itemsToShow.length,
                );
                final booksPage = itemsToShow.sublist(startIndex, endIndex);

                final columnWidths = <double>[
                  80, // Portada
                  180, // Título
                  150, // Subtítulo
                  140, // Autor
                  120, // Editorial
                  120, // Colección
                  60, // Año
                  120, // ISBN
                  60, // Edición
                  60, // Copias
                  80, // Precio
                  150, // Área
                ];

                return Column(
                  children: [
                    CustomTable(
                      headers: [
                        'Portada',
                        'Título',
                        'Subtítulo',
                        'Autor',
                        'Editorial',
                        'Colección',
                        'Año',
                        'ISBN',
                        'Edición',
                        'Copias',
                        'Precio',
                        'Área',
                      ],
                      rows: booksPage.map((book) {
                        return [
                          
                          _buildClickableCell(
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                book.imagenUrl ?? 'assets/sinportada.png',
                                height: 100,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Image.asset(
                                  'assets/sinportada.png',
                                  height: 100,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            book
                          ),
                          _buildClickableCell(_buildText(book.titulo),book),
                          _buildClickableCell(_buildText(book.subtitulo ?? '-'),book),
                          _buildClickableCell(_buildText(book.autor),book),
                          _buildClickableCell(_buildText(book.editorial),book),
                          _buildClickableCell(_buildText(book.coleccion ?? '-'), book),
                          _buildClickableCell(_buildText(book.anio.toString()), book),
                          _buildClickableCell(_buildText(book.isbn ?? '-'), book),
                          _buildClickableCell(_buildText(book.edicion.toString()), book),
                          _buildClickableCell(_buildText(book.copias.toString()), book),
                          _buildClickableCell(_buildText(book.areaConocimiento), book),
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
                              '${_currentPage + 1} / ${((itemsToShow.length - 1) / _itemsPerPage).ceil() + 1}',
                            ),
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
                            color: Colors.white70,
                            fontSize: 12,
                          ),
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
