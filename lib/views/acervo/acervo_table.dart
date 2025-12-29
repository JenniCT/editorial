import 'dart:async';
import 'package:flutter/material.dart';
import '../../viewmodels/acervo/acervo_vm.dart';
import '../../models/book_m.dart';

//=========================== IMPORTACIÓN DE WIDGETS ===========================//
import '../../widgets/global/search.dart';
import '../../widgets/modules/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

//=========================== TABLA PRINCIPAL DE ACERVO ===========================//
class AcervoTable extends StatefulWidget {
  final AcervoViewModel viewModel;
  final TextEditingController searchController;
  final Function(Book) onBookSelected;

  // Notifica selección al padre (para exportar)
  final void Function(int selectedCount)? onSelectionChanged;

  const AcervoTable({
    required this.viewModel,
    required this.searchController,
    required this.onBookSelected,
    this.onSelectionChanged,
    super.key,
  });

  @override
  State<AcervoTable> createState() => AcervoTableState();
}

class AcervoTableState extends State<AcervoTable> {
  //=========================== STREAM ===========================//
  StreamSubscription? _subscription;

  //=========================== LISTAS ===========================//
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];

  //=========================== PAGINACIÓN ===========================//
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  //=========================== ESTADO DE BÚSQUEDA ===========================//
  bool _isSearching = false;

  //=========================== SELECCIÓN ===========================//
  bool _selectAll = false;
  int _selectedCount = 0;
  final List<Book> _selectedBooks = [];

  List<Book> get selectedBooks => _selectedBooks;

  //=========================== INIT ===========================//
  @override
  void initState() {
    super.initState();

    // ESCUCHAR STREAM SIN USAR STREAMBUILDER (FIX DE PARPADEO)
    _subscription = widget.viewModel.getAcervosStream().listen((books) {
      // Guardar selección previa
      final prevSelection = {
        for (var b in _allBooks.where((b) => b.selected)) b.id: true
      };

      setState(() {
        _allBooks = books;

        // Restaurar selección
        for (var b in _allBooks) {
          b.selected = prevSelection[b.id] ?? false;
        }

        // Recalcular filtro si está buscando
        if (_isSearching) {
          final query = widget.searchController.text.toLowerCase();
          _filteredBooks = _allBooks.where((b) {
            return b.tituloLower.contains(query) ||
                b.autorLower.contains(query) ||
                (b.subtitulo ?? '').toLowerCase().contains(query) ||
                b.editorialLower.contains(query) ||
                (b.coleccion ?? '').toLowerCase().contains(query) ||
                (b.isbn ?? '').toLowerCase().contains(query) ||
                b.areaLower.contains(query);
          }).toList();
        }

        _updateSelectedCount();
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  //=========================== SELECCIÓN ===========================//
  void _updateSelectedCount() {
    _selectedBooks
      ..clear()
      ..addAll(_allBooks.where((b) => b.selected));

    _selectedCount = _selectedBooks.length;

    widget.onSelectionChanged?.call(_selectedCount);
    setState(() {});
  }

  //=========================== BÚSQUEDA ===========================//
  void _handleSearchResults(List<Book> results) {
    setState(() {
      _filteredBooks = results;
      _isSearching = widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  //=========================== CELDAS ===========================//
  Widget _buildClickableCell(Widget child, Book book) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onBookSelected(book),
        child: SizedBox(width: double.infinity, child: child),
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

  //=========================== CABECERAS ===========================//
  List<Widget> _buildHeaders(bool enableSelectAll) {
    return [
      IconButton(
        icon: Icon(
          _selectAll
              ? Icons.check_box_outlined
              : Icons.check_box_outline_blank_outlined,
          color: Colors.white,
        ),
        onPressed: enableSelectAll
            ? () {
                setState(() {
                  _selectAll = !_selectAll;
                  for (var b in _allBooks) {
                    b.selected = _selectAll;
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

  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[50, 100, 320, 320, 90, 320];

    //=========================== PANEL SUPERIOR ===========================//
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
                  (book.almacen).toString().contains(query) ||
                  (book.estante).toString().contains(query) ||
                  (book.copias).toString().contains(query) ||
                  book.areaLower.contains(query),
            ),
          ),
          const SizedBox(width: 12),
          ActionButton(
              icon: Icons.filter_list,
              text: 'Filtrar',
              type: ActionType.secondary,
              onPressed: () {}),
          const SizedBox(width: 12),
          ActionButton(
              icon: Icons.sort,
              text: 'Ordenar',
              type: ActionType.secondary,
              onPressed: () {}),
        ],
      );
    }

    //=========================== FUENTE PARA TABLA ===========================//
    final booksToShow = _isSearching ? _filteredBooks : _allBooks;

    if (booksToShow.isEmpty) {
      return CustomTable(
        headers: _buildHeaders(false),
        rows: const [],
        width: 1200,
        columnWidths: columnWidths,
        topWidget: buildTopWidget(),
      );
    }

    //=========================== PAGINACIÓN ===========================//
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, booksToShow.length);

    final books = booksToShow.sublist(startIndex, endIndex);

    _selectAll = books.isNotEmpty && books.every((b) => b.selected);

    //=========================== RENDER ===========================//
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Text(
                '$_selectedCount elemento(s) seleccionados',
                style: const TextStyle(
                  color: Color(0xFF1C2532),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          //=========================== TABLA ===========================//
          CustomTable(
            headers: _buildHeaders(true),
            rows: books.map((book) {
              return [
                IconButton(
                  icon: Icon(
                    book.selected
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank_outlined,
                    color:
                        book.selected ? const Color(0xFF1C2532) : Colors.white,
                  ),
                  onPressed: () {
                    book.selected = !book.selected;
                    _updateSelectedCount();
                  },
                ),
                _buildClickableCell(
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (book.imagenUrl != null &&
                            book.imagenUrl!.startsWith('http'))
                        ? Image.network(book.imagenUrl!,
                            height: 100, width: 100, fit: BoxFit.cover)
                        : Image.asset('assets/images/sinportada.png'),
                  ),
                  book,
                ),
                _buildClickableCell(_buildText(book.titulo), book),
                _buildClickableCell(_buildText(book.autor), book),
                _buildClickableCell(
                    _buildText(book.copias.toString()), book),
                _buildClickableCell(
                    _buildText(book.areaConocimiento), book),
              ];
            }).toList(),
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          ),

          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mostrando ${booksToShow.length} resultado(s)',
                style: const TextStyle(
                  color: Color(0xFF1C2532),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          if (booksToShow.length > _itemsPerPage)
            PaginationWidget(
              currentPage: _currentPage,
              totalItems: booksToShow.length,
              itemsPerPage: _itemsPerPage,
              onPageChanged: (page) => setState(() {
                _currentPage = page;
              }),
            ),
        ],
      ),
    );
  }
}
