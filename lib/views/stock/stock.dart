import 'package:flutter/material.dart';

// MODELO
import '../../models/book_m.dart';
// VISTAMODELO
import '../../viewmodels/book/book_vm.dart';
// VISTAS
import 'import.dart';
import 'export.dart';
import 'add_bk.dart';
import '../book/details_bk.dart';
// WIDGETS
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';
import '../../widgets/stock/hoverbutton.dart';
import '../../widgets/stock/elevatedbutton.dart';

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

  // VARIABLE PARA EL LIBRO SELCCIONADO Y ESTADO DE DETALLE
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
                      HoverButton(
                        icon: Icons.filter_list,
                        text: 'Filtrar',
                        onPressed: () {
                          // Acción de filtrado
                        },
                        color: Colors.white
                      ),
                      HoverButton(
                        icon: Icons.download,
                        text: 'Exportar',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const ExportadorCSV(),
                          );
                        },
                        color: Colors.white,
                      ),
                      HoverButton(
                        icon: Icons.upload,
                        text: 'Importar',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const ImportadorCSV(),
                          );
                        },
                        color: Colors.white,

                      ),
                      IntrinsicWidth(
                        child: IntrinsicHeight(
                          child: ElevatedHoverButton(
                            icon: Icons.add,
                            text: 'Agregar libro',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddBookDialog(
                                  onAdd: (newBook) => _viewModel.addBook(newBook, context),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),                ),
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
                      style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.702)),
                    ),
                  );
                }

                // PAGINACIÓN
                final startIndex = _currentPage * _booksPerPage;
                final endIndex =
                    (startIndex + _booksPerPage).clamp(0, booksToShow.length);
                final books = booksToShow.sublist(startIndex, endIndex);

                // ANCHOS DEFINIDOS
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
                          //CELDA DE IMAGEN DEL LIBRO EN LA TABLA
                          _buildClickableCell(
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: (book.imagenUrl != null && book.imagenUrl!.startsWith('http'))
                                  ? Image.network(
                                      book.imagenUrl!,
                                      height: 100,
                                      width: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _,_) => Image.asset(
                                        'assets/sinportada.png',
                                        height: 100,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/sinportada.png',
                                      height: 100,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            book,
                          ),

                          // CELDA DE TEXTO DEL LIBRO EN LA TABLA
                          _buildClickableCell(_buildText(book.titulo), book),
                          _buildClickableCell(_buildText(book.subtitulo ?? '-'), book),
                          _buildClickableCell(_buildText(book.autor), book),
                          _buildClickableCell(_buildText(book.editorial), book),
                          _buildClickableCell(_buildText(book.coleccion ?? '-'), book),
                          _buildClickableCell(_buildText(book.anio.toString()), book),
                          _buildClickableCell(_buildText(book.isbn ?? '-'), book),
                          _buildClickableCell(_buildText(book.edicion.toString()), book),
                          _buildClickableCell(_buildText(book.copias.toString()), book),
                          _buildClickableCell(_buildText('\$${book.precio.toStringAsFixed(2)}'), book),
                          _buildClickableCell(_buildText(book.estante.toString()), book),
                          _buildClickableCell(_buildText(book.almacen.toString()), book),
                          _buildClickableCell(_buildText(book.areaConocimiento), book),
                        ];
                      }).toList(),
                      columnWidths: columnWidths,
                    ),
                    // MOSTRAR MENSAJE DE RESULTADOS DE BÚSQUEDA
                    if (_isSearching)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Mostrando ${booksToShow.length} resultado(s) de búsqueda',
                          style: const TextStyle(
                              color: Color.fromARGB(179, 0, 0, 0), fontSize: 16),
                        ),
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

                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //WIDGET PARA MOSTRAR TEXTO EN LA TABLA
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