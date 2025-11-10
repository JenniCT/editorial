import 'package:flutter/material.dart'; 
import '../../models/book_m.dart';
import '../../viewmodels/book/book_vm.dart';

//=========================== IMPORTACIÓN DE WIDGETS ===========================//
// IMPORTA COMPONENTES REUTILIZABLES DE UI, COMO TABLAS, BUSQUEDAS Y BOTONES
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

//=========================== WIDGET PRINCIPAL DE INVENTARIO ===========================//
// ESTE WIDGET MUESTRA LA LISTA DE LIBROS CON FILTROS, SELECCIÓN Y PAGINACIÓN
class InventarioTable extends StatefulWidget {
  final BookViewModel viewModel;
  final TextEditingController searchController;
  final Function(Book) onBookSelected;

  const InventarioTable({
    required this.viewModel,
    required this.searchController,
    required this.onBookSelected,
    super.key,
  });

  @override
  State<InventarioTable> createState() => _InventarioTableState();
}

//=========================== ESTADO DEL WIDGET ===========================//
// MANTIENE EL ESTADO DE LA TABLA, SELECCIONES, BÚSQUEDA Y PAGINACIÓN
class _InventarioTableState extends State<InventarioTable> {
  List<Book> _filteredBooks = [];
  List<Book> _allBooks = [];
  int _currentPage = 0;
  final int _booksPerPage = 10;
  bool _isSearching = false;
  bool _selectAll = false;
  int _selectedCount = 0;

  //=========================== MÉTODO DE ACTUALIZACIÓN DE SELECCIÓN ===========================//
  // ACTUALIZA EL CONTADOR DE LIBROS SELECCIONADOS PARA MOSTRARLO EN LA INTERFAZ
  void _updateSelectedCount() {
    if (mounted) {
      setState(() {
        _selectedCount = _allBooks.where((b) => b.selected).length;
      });
    }
  }

  //=========================== MÉTODO DE FILTRADO ===========================//
  // ACTUALIZA LA LISTA DE LIBROS FILTRADOS CUANDO EL USUARIO BUSCA
  void _handleSearchResults(List<Book> results) {
    setState(() {
      _filteredBooks = results;
      _isSearching =
          results.isNotEmpty || widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  //=========================== CELDA CLICKABLE ===========================//
  // ENVUELVE UN WIDGET PARA QUE RESPONDA A CLICS Y CAMBIE EL ESTADO SELECCIONADO
  Widget _buildClickableCell(Widget child, Book book) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onBookSelected(book),
        child: SizedBox(width: double.infinity, height: double.infinity, child: child),
      ),
    );
  }

  //=========================== TEXTOS EN CELDAS ===========================//
  // PADDING Y COLOR PARA TEXTO, ASEGURA LEGIBILIDAD Y CONSISTENCIA VISUAL
  Widget _buildText(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[50, 100, 320, 320, 90, 320];

    //=========================== WIDGET SUPERIOR ===========================//
    // FILTROS, BUSCADOR Y ACCIONES DEL USUARIO PARA INTERACCIÓN RÁPIDA
    Widget buildTopWidget() {
      return Row(
        children: [
          Expanded(
            child: Search<Book>(
              controller: widget.searchController,
              allItems: _allBooks,
              onResults: _handleSearchResults,
              filter: (book, query) =>
                  book.tituloLower.contains(query) ||
                  book.autorLower.contains(query) ||
                  (book.subtitulo ?? '').toLowerCase().contains(query) ||
                  book.editorialLower.contains(query) ||
                  (book.coleccion ?? '').toLowerCase().contains(query) ||
                  (book.isbn ?? '').toLowerCase().contains(query) ||
                  book.estante.toString().contains(query) ||
                  book.almacen.toString().contains(query) ||
                  book.copias.toString().contains(query) ||
                  book.areaLower.contains(query),
            ),
          ),
          const SizedBox(width: 12),
          ActionButton(
            icon: Icons.filter_list,
            text: 'Filtrar',
            type: ActionType.secondary,
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          ActionButton(
            icon: Icons.sort,
            text: 'Ordenar',
            type: ActionType.secondary,
            onPressed: () {},
          ),
        ],
      );
    }

    //=========================== STREAM DE LIBROS ===========================//
    // ESCUCHA CAMBIOS EN LA LISTA DE LIBROS Y ACTUALIZA LA TABLA EN TIEMPO REAL
    return StreamBuilder<List<Book>>(
      stream: widget.viewModel.getBooksStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // MUESTRA TABLA VACÍA MIENTRAS SE CARGAN LOS DATOS
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          );
        }

        //=========================== MANTENER SELECCIONES ===========================//
        // SI EL USUARIO HABÍA SELECCIONADO LIBROS, CONSERVA SU ESTADO
        final previousSelections = {
          for (var b in _allBooks.where((b) => b.selected)) b.id: true,
        };

        _allBooks = snapshot.data ?? [];

        for (var book in _allBooks) {
          if (previousSelections.containsKey(book.id)) {
            book.selected = true;
          }
        }

        List<Book> booksToShow = _isSearching ? _filteredBooks : _allBooks;

        if (_allBooks.isEmpty || (_isSearching && booksToShow.isEmpty)) {
          // MUESTRA TABLA VACÍA SI NO HAY RESULTADOS
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          );
        }

        //=========================== PAGINACIÓN ===========================//
        // LIMITA LA CANTIDAD DE LIBROS VISIBLES POR PÁGINA
        final startIndex = _currentPage * _booksPerPage;
        final endIndex =
            (startIndex + _booksPerPage).clamp(0, booksToShow.length);
        final books = booksToShow.sublist(startIndex, endIndex);

        // ACTUALIZA EL CONTADOR DE SELECCIÓN DESPUÉS DEL BUILD
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSelectedCount();
        });

        // ACTUALIZA ESTADO DE "SELECCIONAR TODOs"
        _selectAll = books.isNotEmpty && books.every((b) => b.selected == true);

        //=========================== RENDERIZADO DE LA TABLA ===========================//
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //=========================== CONTADOR DE ELEMENTOS SELECCIONADOS ===========================//
              if (_selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    '$_selectedCount elemento(s) seleccionados',
                    style: const TextStyle(
                        color: Color(0xFF1C2532),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto'),
                  ),
                ),

              //=========================== TABLA DE LIBROS ===========================//
              // COLOR DE TEXTO BLANCO PARA CONTRASTE, FILAS CLICKABLES PARA INTERACCIÓN
              CustomTable(
                headers: _buildHeaders(true),
                rows: books.map((book) {
                  return [
                    // ICONO DE SELECCIÓN INDIVIDUAL
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        key: ValueKey(book.selected),
                        icon: Icon(
                          book.selected
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: book.selected
                              ? Color(0xFF1C2532) // COLOR VERDE/NEUTRO PARA SELECCIONADO
                              : Colors.white, // COLOR BLANCO PARA NO SELECCIONADO
                        ),
                        onPressed: () {
                          setState(() {
                            book.selected = !book.selected;
                          });
                          _updateSelectedCount();
                        },
                      ),
                    ),

                    // IMAGEN DEL LIBRO CON REDONDEO Y PLACEHOLDER
                    _buildClickableCell(
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (book.imagenUrl != null &&
                                book.imagenUrl!.startsWith('http'))
                            ? Image.network(
                                book.imagenUrl!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    Image.asset('assets/images/sinportada.png'),
                              )
                            : Image.asset('assets/images/sinportada.png'),
                      ),
                      book,
                    ),

                    // TEXTO CLICKABLE EN CADA COLUMNA
                    _buildClickableCell(_buildText(book.titulo), book),
                    _buildClickableCell(_buildText(book.autor), book),
                    _buildClickableCell(_buildText(book.copias.toString()), book),
                    _buildClickableCell(
                        _buildText(book.areaConocimiento), book),
                  ];
                }).toList(),
                columnWidths: columnWidths,
                width: 1200,
                topWidget: buildTopWidget(),
              ),

              //=========================== INDICADOR DE RESULTADOS DE BÚSQUEDA ===========================//
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Mostrando ${booksToShow.length} resultado(s)',
                    style: const TextStyle(
                        color: Color(0xFF1C2532),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto'),
                  ),
                ),

              //=========================== PAGINACIÓN ===========================//
              if (booksToShow.length > _booksPerPage)
                PaginationWidget(
                  currentPage: _currentPage,
                  totalItems: booksToShow.length,
                  itemsPerPage: _booksPerPage,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  //=========================== HEADER DE TABLA ===========================//
  // INCLUYE ICONO "SELECCIONAR TODOS" Y NOMBRES DE COLUMNAS
  List<Widget> _buildHeaders(bool enableSelectAll) {
    return [
      IconButton(
        icon: Icon(
          _selectAll
              ? Icons.check_box_outlined
              : Icons.check_box_outline_blank_outlined,
          color: Color(0xFF1C2532),
        ),
        onPressed: enableSelectAll
            ? () {
                setState(() {
                  _selectAll = !_selectAll;

                  for (var book in _allBooks) {
                    book.selected = _selectAll;
                  }
                });
                _updateSelectedCount();
              }
            : null,
      ),
      const Text('Portada', style: TextStyle(color: Colors.white)),
      const Text('Título', style: TextStyle(color: Colors.white)),
      const Text('Autor', style: TextStyle(color: Colors.white)),
      const Text('Stock', style: TextStyle(color: Colors.white)),
      const Text('Área de conocimiento', style: TextStyle(color: Colors.white)),
    ];
  }
}
