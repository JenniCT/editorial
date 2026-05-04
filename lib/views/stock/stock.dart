import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

//=========================== MODELOS ===========================//
import '../../models/book_m.dart';

//=========================== VISTAMODELOS ===========================//
import '../../viewmodels/book/book_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
import 'add_bk.dart';
import '../book/details_bk.dart';
import '../book/edit_bk.dart';
import '../basic/export/download_dialog.dart';

//=========================== WIDGETS ===========================//
import '../../widgets/layout/page_header.dart';

import '../../widgets/buttons/primary_btn.dart';
import '../../widgets/buttons/secondary_btn.dart';

import '../../widgets/modules/table.dart';
import '../../widgets/modules/table_text.dart';
import '../../widgets/modules/table_checkbox.dart';
import '../../widgets/modules/table_actions.dart';
import '../../widgets/modules/area_badge.dart';

import '../../widgets/global/search.dart';
import '../../widgets/modules/pagination.dart';


class InventarioPage extends StatefulWidget {
  final Function(Book) onBookSelected;

  const InventarioPage({required this.onBookSelected, super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  //=========================== CONTROLADORES Y ESTADOS ===========================//
  final BookViewModel _viewModel = BookViewModel();
  final ExportViewModel _exportVM = ExportViewModel();
  final TextEditingController _searchController = TextEditingController();

  // SUSCRIPCIÓN AL STREAM (reemplaza al StreamBuilder)
  StreamSubscription<List<Book>>? _bookSubscription;

  // BÚSQUEDA
  List<Book>? _searchResults;
  bool _isSearching = false;

  // SELECCIÓN
  List<Book> _allBooks = [];
  final List<Book> _selectedBooks = [];
  int _selectedCount = 0;
  bool _selectAll = false;

  // PAGINACIÓN
  int _currentPage = 0;
  final int _booksPerPage = 10;


  //=========================== INIT: suscripción única al stream ===========================//
  @override
  void initState() {
    super.initState();
    _bookSubscription = _viewModel.getBooksStream().listen((books) {
      if (!mounted) return;

      // RESTAURAR SELECCIONES PREVIAS
      final prev = {for (var b in _allBooks.where((b) => b.selected)) b.id: true};
      for (var b in books) {
        if (prev.containsKey(b.id)) b.selected = true;
      }

      setState(() {
        _allBooks = books;
        _selectedBooks
          ..clear()
          ..addAll(_allBooks.where((b) => b.selected));
        _selectedCount = _selectedBooks.length;
        _selectAll = _allBooks.isNotEmpty && _allBooks.every((b) => b.selected);
      });
    });
  }


  //=========================== DETALLE ===========================//
  void _handleBookSelection(Book book) {
    mostrarDetalleLibro(
      context,
      book,
      onUpdate: (updatedBook) {
        // Refleja cambios en _allBooks si el libro fue editado
        setState(() {
          final idx = _allBooks.indexWhere((b) => b.id == updatedBook.id);
          if (idx != -1) _allBooks[idx] = updatedBook;
        });
      },
    );
  }


  //=========================== BÚSQUEDA ===========================//
  void _handleSearchResults(List<Book> results) {
    setState(() {
      _searchResults = results;
      _isSearching = results.isNotEmpty || _searchController.text.isNotEmpty;
      _currentPage = 0;
    });
  }


  //=========================== SELECCIÓN ===========================//
  void _updateSelectedCount() {
    if (!mounted) return;
    setState(() {
      _selectedBooks
        ..clear()
        ..addAll(_allBooks.where((b) => b.selected));
      _selectedCount = _selectedBooks.length;
      _selectAll = _allBooks.isNotEmpty && _allBooks.every((b) => b.selected);
    });
  }


  //=========================== CELDAS ===========================//
  Widget _buildClickableCell(Widget child, Book book) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleBookSelection(book),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }


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
                  for (var book in _allBooks) {
                    book.selected = _selectAll;
                  }
                  _updateSelectedCount();
                });
              }
            : null,
      ),
      const Text('Portada'),
      const Text('Título'),
      const Text('Autor'),
      const Text('Stock'),
      const Text('Área de conocimiento'),
      const Text('Acciones'),
    ];
  }


  @override
  Widget build(BuildContext context) {
    final columnWidths = <double>[
      60,   // checkbox
      90,   // portada
      270,  // título
      270,  // autor
      90,   // stock
      180,  // área de conocimiento
      220,  // acciones
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== ENCABEZADO ===========================//
            PageHeader(
              title: 'Inventario',
              actions: [
                //=========================== IMPORTAR ===========================//
                SecondaryButton(
                  icon: CupertinoIcons.arrow_up,
                  text: 'Importar',
                  onPressed: () {},
                ),

                //=========================== EXPORTAR ===========================//
                SecondaryButton(
                  icon: CupertinoIcons.arrow_down,
                  text: 'Exportar',
                  onPressed: () async {
                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: _viewModel.booksCount,
                      selectedItems: _selectedCount,
                      entityName: 'libros',
                    );

                    if (option == null) return;

                    if (option == 'all') {
                      final allBooks = await _viewModel.getAllBooksAsMap();
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: allBooks,
                        fileName: 'libros_activos',
                        context: context,
                      );
                    } else if (option == 'selected') {
                      if (_selectedBooks.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No hay libros seleccionados para exportar')),
                        );
                        return;
                      }
                      final selectedData =
                          await _viewModel.getSelectedBooksAsMap(_selectedBooks);
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: selectedData,
                        fileName: 'libros_seleccionados',
                        context: context,
                      );
                    }
                  },
                ),

                //=========================== GENERAR QRS ===========================//
                SecondaryButton(
                  text: 'Generar QRs',
                  icon: CupertinoIcons.qrcode,
                  onPressed: () {},
                ),

                //=========================== AGREGAR NUEVO LIBRO ===========================//
                PrimaryButton(
                  icon: CupertinoIcons.add,
                  text: 'Agregar libro',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddBookDialog(
                      onAdd: (newBook) => _viewModel.addBook(newBook, context),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            //=========================== TABLA (sin StreamBuilder) ===========================//
            Expanded(
              child: Builder(
                builder: (context) {
                  final List<Book> booksToShow =
                      _isSearching && _searchResults != null
                          ? _searchResults!
                          : _allBooks;

                  final startIndex = _currentPage * _booksPerPage;
                  final endIndex =
                      (startIndex + _booksPerPage).clamp(0, booksToShow.length);
                  final books = booksToShow.isNotEmpty
                      ? booksToShow.sublist(startIndex, endIndex)
                      : <Book>[];

                  final bool hasData = _allBooks.isNotEmpty;
                  final bool isEmpty =
                      _allBooks.isEmpty || (_isSearching && booksToShow.isEmpty);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //=========================== BÚSQUEDA, FILTRO Y ORDEN ===========================//
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Search<Book>(
                              controller: _searchController,
                              hintText: 'Buscar por título, autor, área, etc.',
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

                          SecondaryButton(
                            icon: Icons.filter_list,
                            text: 'Filtrar',
                            onPressed: () {},
                          ),

                          const SizedBox(width: 8),

                          SecondaryButton(
                            icon: Icons.sort,
                            text: 'Ordenar',
                            onPressed: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      //=========================== CONTADOR DE SELECCIONADOS ===========================//
                      if (_selectedCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 8),
                          child: Text(
                            '$_selectedCount elemento(s) seleccionados',
                            style: const TextStyle(
                              color: Color(0xFF1C2532),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),

                      //=========================== TABLA ===========================//
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTable(
                                headers: _buildHeaders(hasData && !isEmpty),
                                rows: isEmpty
                                    ? []
                                    : books.map((book) {
                                        return [
                                          //=========================== CHECKBOX ===========================//
                                          TableCheckbox(
                                            value: book.selected,
                                            onTap: () {
                                              setState(() {
                                                book.selected = !book.selected;
                                              });
                                              _updateSelectedCount();
                                            },
                                          ),

                                          //=========================== PORTADA ===========================//
                                          _buildClickableCell(
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: (book.imagenUrl != null &&
                                                      book.imagenUrl!.startsWith('http'))
                                                  ? CachedNetworkImage(
                                                      imageUrl: book.imagenUrl!,
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                      placeholder: (_, _) => const SizedBox(
                                                        height: 50,
                                                        width: 100,
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget: (_, _, _) => Image.asset(
                                                        'assets/images/sinportada.png',
                                                        height: 50,
                                                        width: 100,
                                                      ),
                                                    )
                                                  : Image.asset(
                                                      'assets/images/sinportada.png',
                                                      height: 50,
                                                      width: 100,
                                                    ),
                                            ),
                                            book,
                                          ),

                                          //=========================== COLUMNAS DE TEXTO ===========================//
                                          _buildClickableCell(TableText(text: book.titulo), book),
                                          _buildClickableCell(TableText(text: book.autor), book),
                                          _buildClickableCell(TableText(text: book.copias.toString()), book),
                                          _buildClickableCell(AreaBadge(area: book.areaConocimiento), book),
                                          TableActions(
                                            showCost: true,
                                            onEdit: () => showEditBookDialog(
                                              context,
                                              book,
                                              onUpdate: (updated) {
                                                setState(() {
                                                  final idx = _allBooks.indexWhere((b) => b.id == updated.id);
                                                  if (idx != -1) _allBooks[idx] = updated;
                                                });
                                              },
                                            ),
                                            showQR: true,
                                            onHistory: () {},
                                            onCost: () {},
                                            onDelete: () {},
                                          ),
                                        ];
                                      }).toList(),
                                columnWidths: columnWidths,
                                width: 1200,
                              ),

                              //=========================== RESULTADOS DE BÚSQUEDA ===========================//
                              if (_isSearching)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Mostrando ${booksToShow.length} resultado(s)',
                                    style: const TextStyle(
                                      color: Color(0xFF1C2532),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),

                              //=========================== PAGINACIÓN ===========================//
                              if (booksToShow.length > _booksPerPage)
                                PaginationWidget(
                                  currentPage: _currentPage,
                                  totalItems: booksToShow.length,
                                  itemsPerPage: _booksPerPage,
                                  onPageChanged: (page) {
                                    setState(() => _currentPage = page);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _bookSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}