import 'package:flutter/material.dart';
import '../../viewmodels/acervo/acervo_vm.dart';
import '../../models/book_m.dart';

//=========================== IMPORTACIÓN DE WIDGETS ===========================//
// IMPORTA COMPONENTES REUTILIZABLES DE UI, COMO TABLAS, BUSQUEDAS Y BOTONES
import '../../widgets/global/search.dart';
import '../../widgets/global/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

class AcervoTable extends StatefulWidget {
  final AcervoViewModel viewModel;
  final TextEditingController searchController;
  final Function(Book) onBookSelected;

  const AcervoTable({
    required this.viewModel,
    required this.searchController,
    required this.onBookSelected,
    super.key,
  });

  @override
  State<AcervoTable> createState() => _AcervoTableState();
}

class _AcervoTableState extends State<AcervoTable> {
  List<Book> _filteredBooks = [];
  List<Book> _allBooks = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isSearching = false;
  bool _selectAll = false;
  int _selectedCount = 0;

  // Actualiza contador de seleccionados (solo se llama dentro de setState)
  void _updateSelectedCount() {
    _selectedCount = _allBooks.where((b) => b.selected).length;
    _selectAll = _allBooks.isNotEmpty && _allBooks.every((b) => b.selected);
  }

  void _handleSearchResults(List<Book> results) {
    setState(() {
      _filteredBooks = results;
      _isSearching = results.isNotEmpty || widget.searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }

  Widget _buildClickableCell(Widget child, Book book) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onBookSelected(book),
        child: SizedBox(width: double.infinity, height: double.infinity, child: child),
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

  List<Widget> _buildHeaders(bool enableSelectAll) {
    return [
      IconButton(
        icon: Icon(
          _selectAll ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
          color: Colors.white,
        ),
        onPressed: enableSelectAll
            ? () {
                setState(() {
                  _selectAll = !_selectAll;
                  for (var book in _allBooks) {
                    book.selected = _selectAll;
                  }
                  _updateSelectedCount();
                });
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
          ActionButton(icon: Icons.filter_list, text: 'Filtrar', type: ActionType.secondary, onPressed: () {}),
          const SizedBox(width: 12),
          ActionButton(icon: Icons.sort, text: 'Ordenar', type: ActionType.secondary, onPressed: () {}),
        ],
      );
    }

    return StreamBuilder<List<Book>>(
      stream: widget.viewModel.getAcervosStream(),
      builder: (context, snapshot) {
        _allBooks = snapshot.data ?? [];

        // Mantener selección previa
        final previousSelections = {for (var b in _allBooks.where((b) => b.selected)) b.id: true};
        for (var book in _allBooks) {
          if (previousSelections.containsKey(book.id)) book.selected = true;
        }

        List<Book> booksToShow = _isSearching ? _filteredBooks : _allBooks;

        if (booksToShow.isEmpty) {
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          );
        }

        // Evitar out of range en paginación
        final startIndex = (_currentPage * _itemsPerPage).clamp(0, booksToShow.length);
        final endIndex = ((startIndex + _itemsPerPage)).clamp(0, booksToShow.length);
        final booksPage = booksToShow.sublist(startIndex, endIndex);

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    '$_selectedCount elemento(s) seleccionados',
                    style: const TextStyle(color: Color(0xFF1C2532), fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              CustomTable(
                headers: _buildHeaders(true),
                rows: booksPage.map((book) {
                  return [
                    // Checkbox
                    IconButton(
                      icon: Icon(
                        book.selected ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                        color: book.selected ? const Color(0xFF1C2532) : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          book.selected = !book.selected;
                          _updateSelectedCount();
                        });
                      },
                    ),
                    // Portada
                    _buildClickableCell(
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (book.imagenUrl != null && book.imagenUrl!.startsWith('http'))
                            ? Image.network(
                                book.imagenUrl!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Image.asset('assets/images/sinportada.png'),
                              )
                            : Image.asset('assets/images/sinportada.png'),
                      ),
                      book,
                    ),
                    _buildClickableCell(_buildText(book.titulo), book),
                    _buildClickableCell(_buildText(book.autor), book),
                    _buildClickableCell(_buildText(book.copias.toString()), book),
                    _buildClickableCell(_buildText(book.areaConocimiento), book),
                  ];
                }).toList(),
                columnWidths: columnWidths,
                width: 1200,
                topWidget: buildTopWidget(),
              ),
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Mostrando ${booksToShow.length} resultado(s)',
                      style: const TextStyle(color: Color(0xFF1C2532), fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              if (booksToShow.length > _itemsPerPage)
                PaginationWidget(
                  currentPage: _currentPage,
                  totalItems: booksToShow.length,
                  itemsPerPage: _itemsPerPage,
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
}
