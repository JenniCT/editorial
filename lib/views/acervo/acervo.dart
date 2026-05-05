import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

//=========================== MODELOS ===========================//
import '../../models/book_m.dart';

//=========================== VISTAMODELOS ===========================//
import '../../viewmodels/acervo/acervo_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
import '../book/details_bk.dart';
import '../book/edit_bk.dart';
import '../acervo/add_acervo.dart';
import '../basic/export/download_dialog.dart';
import '../basic/qr/qr_v.dart';

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

class AcervoPage extends StatefulWidget {
  final Function(Book) onAcervoSelected;

  const AcervoPage({required this.onAcervoSelected, super.key});

  @override
  State<AcervoPage> createState() => _AcervoPageState();
}

class _AcervoPageState extends State<AcervoPage> {
  //=========================== CONTROLADORES Y ESTADOS ===========================//
  final AcervoViewModel _viewModel = AcervoViewModel();
  final ExportViewModel _exportVM = ExportViewModel();
  final TextEditingController _searchController = TextEditingController();

  // STREAM
  StreamSubscription? _subscription;

  // LISTAS
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];

  // BÚSQUEDA
  bool _isSearching = false;

  // SELECCIÓN
  bool _selectAll = false;
  int _selectedCount = 0;
  final List<Book> _selectedBooks = [];

  // PAGINACIÓN
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  //=========================== INIT ===========================//
  @override
  void initState() {
    super.initState();

    _subscription = _viewModel.getAcervosStream().listen((books) {
      if (!mounted) return;

      // GUARDAR SELECCIÓN PREVIA ANTES DE REEMPLAZAR LA LISTA
      final prevSelection = {
        for (var b in _allBooks.where((b) => b.selected)) b.id: true
      };

      setState(() {
        _allBooks = books;

        // RESTAURAR SELECCIÓN
        for (var b in _allBooks) {
          b.selected = prevSelection[b.id] ?? false;
        }

        // RECALCULAR FILTRO SI ESTÁ BUSCANDO
        if (_isSearching) {
          final query = _searchController.text.toLowerCase();
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

  //=========================== DETALLE ===========================//
  void _handleBookSelection(Book book) {
    mostrarDetalleLibro(
      context,
      book,
      onUpdate: (updatedBook) {
        setState(() {
          final idx = _allBooks.indexWhere((b) => b.id == updatedBook.id);
          if (idx != -1) _allBooks[idx] = updatedBook;
        });
      },
    );
  }

  //=========================== SELECCIÓN ===========================//
  void _updateSelectedCount() {
    _selectedBooks
      ..clear()
      ..addAll(_allBooks.where((b) => b.selected));

    _selectedCount = _selectedBooks.length;
    setState(() {});
  }

  //=========================== BÚSQUEDA ===========================//
  void _handleSearchResults(List<Book> results) {
    setState(() {
      _filteredBooks = results;
      _isSearching = _searchController.text.isNotEmpty;
      _currentPage = 0;
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
                  for (var b in _allBooks) {
                    b.selected = _selectAll;
                  }
                });
                _updateSelectedCount();
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
      60,
      90,
      270,
      270,
      90,
      180,
      220,
    ];

    final booksToShow = _isSearching ? _filteredBooks : _allBooks;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, booksToShow.length);
    final books = booksToShow.isNotEmpty
        ? booksToShow.sublist(startIndex, endIndex)
        : <Book>[];

    _selectAll = books.isNotEmpty && books.every((b) => b.selected);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== ENCABEZADO ===========================//
            PageHeader(
              title: 'Acervo',
              actions: [

                //=========================== EXPORTAR ===========================//
                SecondaryButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () async {
                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: _viewModel.acervoBooksCount,
                      selectedItems: _selectedCount,
                      entityName: 'libros',
                    );

                    if (option == null) return;

                    if (option == 'all') {
                      final allBooks = await _viewModel.getAllAcervoBooksAsMap();
                      if (!context.mounted) return;
                      await _exportVM.exportToExcel(
                        data: allBooks,
                        fileName: 'acervo_completo',
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
                        fileName: 'acervo_seleccionado',
                        context: context,
                      );
                    }
                  },
                ),

                //=========================== GENERAR QRs ===========================//
                SecondaryButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                ),

                //=========================== AGREGAR NUEVO ACERVO ===========================//
                PrimaryButton(
                  icon: CupertinoIcons.add,
                  text: 'Agregar acervo',
                  onPressed: () => showAddAcervoDialog(
                    context,
                    (newBook) => _viewModel.addAcervo(newBook, context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            //=========================== BÚSQUEDA, FILTRO Y ORDEN ===========================//
            Row(
              children: [
                Expanded(
                  child: Search<Book>(
                    controller: _searchController,
                    allItems: _allBooks,
                    hintText: 'Buscar por título, autor, área, etc.',
                    onResults: _handleSearchResults,
                    filter: (book, query) =>
                        book.tituloLower.contains(query) ||
                        book.autorLower.contains(query) ||
                        (book.subtitulo ?? '').toLowerCase().contains(query) ||
                        book.editorialLower.contains(query) ||
                        (book.coleccion ?? '').toLowerCase().contains(query) ||
                        (book.isbn ?? '').toLowerCase().contains(query) ||
                        book.almacen.toString().contains(query) ||
                        book.estante.toString().contains(query) ||
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
                const SizedBox(width: 12),
                SecondaryButton(
                  icon: Icons.sort,
                  text: 'Ordenar',
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            //=========================== TABLA ===========================//
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //=========================== CONTADOR DE SELECCIONADOS ===========================//
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

                    CustomTable(
                      headers: _buildHeaders(booksToShow.isNotEmpty),
                      rows: books.map((book) {
                        return [
                          //=========================== CHECKBOX ===========================//
                          TableCheckbox(
                            value: book.selected,
                            onTap: () {
                              book.selected = !book.selected;
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
                            onQr: () => showBookQrDialog(context,book,),
                            onHistory: () {},
                            onCost: () {},
                            onDelete: () {},
                          ),
                        ];
                      }).toList(),
                      width: 1200,
                      columnWidths: columnWidths,
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
                          ),
                        ),
                      ),

                    //=========================== PAGINACIÓN ===========================//
                    if (booksToShow.length > _itemsPerPage)
                      PaginationWidget(
                        currentPage: _currentPage,
                        totalItems: booksToShow.length,
                        itemsPerPage: _itemsPerPage,
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}