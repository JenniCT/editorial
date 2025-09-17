import 'package:flutter/material.dart';
import '../../widgets/global/table.dart';

// MODELO
import '../../models/book_m.dart';
// VISTAMODELO
import '../../viewmodels/book_vm.dart';
// VISTAS
import 'import.dart';
import 'export_v.dart';
import 'add_bk.dart';
import '../book/details_bk.dart';
// WIDGETS
import '../../widgets/global/search.dart';

class InventarioPage extends StatefulWidget {
  final Function(Book) onBookSelected;

  const InventarioPage({required this.onBookSelected, super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final BookViewModel _viewModel = BookViewModel();
  final TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];
  List<Book> _allBooks = [];
  int _currentPage = 0;
  final int _booksPerPage = 10;
  bool _isSearching = false;

  // NUEVO: libro seleccionado y control de detalle
  Book? _selectedBook;
  bool _showingDetail = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleSearchResults(List<Book> results) {
    setState(() {
      _filteredBooks = results;
      _isSearching = results.isNotEmpty || _searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  // NUEVO: manejar selección de libro
  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si estamos mostrando detalle, renderizamos la página de detalle
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
            // 🔍 BARRA DE BÚSQUEDA
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Search(
                    controller: _searchController,
                    allBooks: _allBooks,
                    onResults: _handleSearchResults,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),

            // TÍTULO Y BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Libros',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      _buildOutlinedButton(Icons.filter_list, 'Filtrar', () {}),
                      _buildOutlinedButton(Icons.download, 'Exportar', () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(child: ExportarCSV()),
                        );
                      }),
                      _buildOutlinedButton(Icons.upload, 'Importar', () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(child: ImportadorCSV()),
                        );
                      }),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar libro'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddBookDialog(
                              onAdd: (newBook) =>
                                  _viewModel.addBook(newBook, context),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
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

            // TABLA DE LIBROS
            StreamBuilder<List<Book>>(
              stream: _viewModel.getBooksStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay libros disponibles'));
                }

                _allBooks = snapshot.data!;
                List<Book> booksToShow =
                    _isSearching ? _filteredBooks : _allBooks;

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

                // PAGINACIÓN
                final startIndex = _currentPage * _booksPerPage;
                final endIndex =
                    (startIndex + _booksPerPage).clamp(0, booksToShow.length);
                final books = booksToShow.sublist(startIndex, endIndex);

                // Definir anchos de columnas (en pixeles)
                final columnWidths = <double>[
                  80, 180, 150, 140, 120, 120, 60, 120, 60, 60, 80, 60, 80, 150
                ];

                return Column(
                  children: [
                    CustomTable(
                      headers: [
                        'Portada', 'Título', 'Subtítulo', 'Autor',
                        'Editorial', 'Colección', 'Año', 'ISBN',
                        'Edición', 'Copias', 'Precio', 'Estante',
                        'Almacén', 'Área de conocimiento'
                      ],
                      rows: books.map((book) {
                        return [
                          // Portada con borde redondeado y click para detalle
                          GestureDetector(
                            onTap: () => _handleBookSelection(book),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                book.imagenUrl ?? 'assets/sinportada.png',
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
                          ),
                          _buildText(book.titulo,),
                          _buildText(book.subtitulo ?? '-'),
                          _buildText(book.autor),
                          _buildText(book.editorial),
                          _buildText(book.coleccion ?? '-'),
                          _buildText(book.anio.toString()),
                          _buildText(book.isbn ?? '-'),
                          _buildText(book.edicion.toString()),
                          _buildText(book.copias.toString()),
                          _buildText('\$${book.precio.toStringAsFixed(2)}'),
                          _buildText(book.estante.toString()),
                          _buildText(book.almacen.toString()),
                          _buildText(book.areaConocimiento),
                        ];
                      }).toList(),
                      columnWidths: columnWidths,
                    ),

                    // CONTROLES DE PAGINACIÓN
                    if (booksToShow.length > _booksPerPage)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: _currentPage > 0
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '${_currentPage + 1} / ${((booksToShow.length - 1) / _booksPerPage).ceil() + 1}',
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: endIndex < booksToShow.length
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),

                    // Información de resultados
                    if (_isSearching)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Mostrando ${booksToShow.length} resultado(s) de búsqueda',
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
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );

  Widget _buildText(String text) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text,
            overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
      );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

