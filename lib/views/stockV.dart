import 'package:flutter/material.dart';
import 'dart:ui';
//MODELO
import '../models/bookM.dart';
//VISTAMODELO
import '../viewmodels/bookVM.dart';
//VISTAS
import '../views/import.dart';
import '../views/export.dart';
import 'addbk.dart';

class InventarioPage extends StatefulWidget {
  final Function(Book) onBookSelected;

  const InventarioPage({required this.onBookSelected, super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final BookViewModel _viewModel = BookViewModel();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  final int _booksPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
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
            //BARRA DE BÚSQUEDA
            LayoutBuilder(
              builder: (context, constraints) {
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //BUSCADOR
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar libros...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                    // TITULO Y BOTONES
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
                              // FILTRO
                              _buildOutlinedButton(Icons.filter_list, 'Filtrar', () {}),
                              // EXPORTAR
                              _buildOutlinedButton(Icons.download, 'Exportar', () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                        Dialog(child: ExportarCSV()),
                                  );
                                },
                              ),
                              // IMPORTAR
                              _buildOutlinedButton(Icons.upload, 'Importar', () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                        Dialog(child: ImportadorCSV()),
                                  );
                                },
                              ),
                              // AGREGAR
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
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // TABLA DE LIBROS
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
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text('No hay libros disponibles'),
                                  );
                                }

                                final query = _searchQuery.toLowerCase();
                                final filteredBooks = snapshot.data!
                                    .where(
                                      (book) => (book.titulo).toLowerCase().contains( query,) ||
                                          (book.autor).toLowerCase().contains( query,) ||
                                          (book.subtitulo ?? '').toLowerCase().contains(query) ||
                                          (book.editorial).toLowerCase().contains(query) ||
                                          (book.coleccion ?? '').toLowerCase().contains(query) ||
                                          (book.isbn ?? '').toLowerCase().contains(query) ||
                                          (book.estante).toString().contains(query,) ||
                                          (book.almacen).toString().contains(query,) ||
                                          (book.copias).toString().contains(query,) ||
                                          (book.areaConocimiento)
                                              .toLowerCase()
                                              .contains(query),
                                    )
                                    .toList();

                                // PAGINACIÓN
                                final startIndex = _currentPage * _booksPerPage;
                                final endIndex = (startIndex + _booksPerPage)
                                    .clamp(0, filteredBooks.length);
                                final books = filteredBooks.sublist(
                                  startIndex,
                                  endIndex,
                                );

                                return Column(
                                  children: [
                                    //ENCABEZADO
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: 1400,
                                        child: _buildHeaderRow(),
                                      ),
                                    ),
                                    const Divider(color: Colors.white54),

                                    // TABLA DE LIBROS
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
                                                          onTap: () => widget
                                                              .onBookSelected(
                                                                book,
                                                              ),
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

                                    // PAGINACIÓN
                                    if (filteredBooks.length > _booksPerPage)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.arrow_left,
                                              ),
                                              onPressed: _currentPage > 0
                                                  ? () {
                                                      setState(() {
                                                        _currentPage--;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(
                                              '${_currentPage + 1} / ${((filteredBooks.length - 1) / _booksPerPage).ceil() + 1}',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.arrow_right,
                                              ),
                                              onPressed:
                                                  endIndex <
                                                      filteredBooks.length
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
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
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
                    errorBuilder: (_, _, _) =>
                        Image.asset('assets/sinportada.png', height: 100, width: 40, fit: BoxFit.cover),
                  )
                : Image.asset(
                    'assets/sinportada.png',
                    height: 100,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
          ),
          const VerticalDivider(),
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white),)),
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
