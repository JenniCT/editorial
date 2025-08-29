import 'package:flutter/material.dart';
import 'dart:ui';
// MODELO
import '../models/book_m.dart';
// VISTAMODELO
import '../viewmodels/book_vm.dart';
// VISTAS
import '../views/import.dart';
import '../views/export_v.dart';
import '../views/add_bk.dart';
//WIDGETS
import '../widgets/search.dart';

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

  @override
  void initState() {
    super.initState();
    
  }

  void _handleSearchResults(List<Book> results) {
    debugPrint('Resultados recibidos: ${results.length}');
    setState(() {
      _filteredBooks = results;
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

            //TÍTULO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Libros',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),

                // BOTONES
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

            //TABLA DE LIBROS
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(47, 65, 87, 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromRGBO(47, 65, 87, 0.3),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 1400,
                        child: Column(
                          children: [
                            const Divider(color: Colors.white54),
                            StreamBuilder<List<Book>>(
                              stream: _viewModel.getBooksStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(child: Text('No hay libros disponibles'));
                                  }

                                  _allBooks = snapshot.data!;
                                  List<Book> booksToShow = _isSearching ? _filteredBooks : _allBooks;

                                  if (_isSearching && _filteredBooks.isEmpty && _searchController.text.isNotEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No se encontraron libros con ese criterio de búsqueda',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  }

                                // PAGINACIÓN
                                final startIndex = _currentPage * _booksPerPage;
                                final endIndex = (startIndex + _booksPerPage)
                                    .clamp(0, booksToShow.length);
                                final books = booksToShow.sublist(
                                  startIndex,
                                  endIndex,
                                );

                                return Column(
                                  children: [
                                    // ENCABEZADO
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: 1400,
                                        child: _buildHeaderRow(),
                                      ),
                                    ),
                                    const Divider(color: Colors.white54),

                                    // FILAS DE LIBROS
                                    SizedBox(
                                      height: 400,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SizedBox(
                                            width: 1400,
                                            child: Column(
                                              children: books
                                                  .map(
                                                    (book) => Column(
                                                      children: [
                                                        BookRow(
                                                          imageUrl: book.imagenUrl ?? 'assets/sinportada.png',
                                                          title: book.titulo,
                                                          subtitle: book.subtitulo ?? '-',
                                                          author: book.autor,
                                                          editorial: book.editorial,
                                                          collection: book.coleccion ?? '-',
                                                          year: book.anio.toString(),
                                                          isbn: book.isbn ?? '-',
                                                          edition: book.edicion.toString(),
                                                          copies: book.copias.toString(),
                                                          total: book.copias.toString(),
                                                          price: '\$${book.precio.toStringAsFixed(2)}',
                                                          estante: book.estante.toString(),
                                                          almacen: book.almacen.toString(),
                                                          area: book.areaConocimiento,
                                                          onTap: () => widget.onBookSelected(book),
                                                        ),
                                                        const Divider(
                                                          color: Colors.white30,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
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

                                    // Mostrar información de resultados
                                    if (_isSearching)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Mostrando ${booksToShow.length} resultado(s) de búsqueda',
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
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
    IconData icon,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
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
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    const headerStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
    return Row(
      children: const [
        Expanded(child: Text('Portada', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Título', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Subtítulo', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Autor', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Editorial', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Colección', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Año', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('ISBN', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Edición', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Copias', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Precio', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Estante', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Almacén', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Área de Conocimiento', style: headerStyle)),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class BookRow extends StatelessWidget {
  final String imageUrl,
      title,
      subtitle,
      author,
      editorial,
      collection,
      year,
      isbn,
      edition,
      copies,
      total,
      price,
      estante,
      almacen,
      area;
  final VoidCallback onTap;

  const BookRow({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.editorial,
    required this.collection,
    required this.year,
    required this.isbn,
    required this.edition,
    required this.copies,
    required this.total,
    required this.price,
    required this.estante,
    required this.almacen,
    required this.area,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/sinportada.png',
                      height: 100,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/sinportada.png',
                    height: 100,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
          ),
          const VerticalDivider(),
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(subtitle, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(author, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(editorial, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(collection, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(year, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(isbn, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(edition, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(copies, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(price, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(estante, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(almacen, style: TextStyle(color: Colors.white))),
          const VerticalDivider(),
          Expanded(child: Text(area, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}