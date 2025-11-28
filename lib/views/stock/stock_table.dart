import 'package:flutter/material.dart';
import '../../models/book_m.dart';
import '../../viewmodels/book/book_vm.dart';

//=========================== IMPORTACIÓN DE WIDGETS ===========================//
// AGRUPACIÓN DE IMPORTS DE WIDGETS AUXILIARES QUE CONSTRUYEN ELEMENTOS REUTILIZABLES
import '../../widgets/global/search.dart';
import '../../widgets/modules/table.dart';
import '../../widgets/table/pagination.dart';
import '../../widgets/modules/action_button.dart';
import '../../widgets/modules/header_button.dart';

//=========================== WIDGET PRINCIPAL DE INVENTARIO ===========================//
// ESTE WIDGET REPRESENTA LA TABLA COMPLETA DE INVENTARIO, MANEJANDO:
// BÚSQUEDA, FILTROS, SELECCIÓN DE LIBROS, PAGINACIÓN Y EVENTOS DE CLICK.
// TONO: PROFESIONAL, CONTENIDO Y EMPÁTICO; EL DISEÑO DEBE TRANSMITIR ORDEN Y CUIDADO.
class InventarioTable extends StatefulWidget {
  final BookViewModel viewModel;
  final TextEditingController searchController;
  final Function(Book) onBookSelected;
  final void Function(int selectedCount)? onSelectionChanged;

  const InventarioTable({
    required this.viewModel,
    required this.searchController,
    required this.onBookSelected,
    this.onSelectionChanged,
    super.key,
  });

  @override
  State<InventarioTable> createState() => InventarioTableState();
}

class InventarioTableState extends State<InventarioTable> {
  //=========================== VARIABLES INTERNAS ===========================//
  // ALMACENA TODOS LOS LIBROS Y LOS QUE PASAN POR FILTRO/BÚSQUEDA
  // PROPÓSITO EMOCIONAL: MANTENER UNA REPRESENTACIÓN CONSISTENTE DEL ESTADO
  List<Book> _filteredBooks = [];
  List<Book> _allBooks = [];

  // VARIABLES DE PAGINACIÓN
  // EXPLICACIÓN: SE USA UNA PÁGINA SIMPLE PARA MANTENER EL RITMO VISUAL Y EVITAR SOBRECARGA
  int _currentPage = 0;
  final int _booksPerPage = 10;

  // ESTADOS DE BÚSQUEDA Y SELECCIÓN
  // INDICADOR: SI HAY UN TEXTO EN LA BÚSQUEDA O RESULTADOS FILTRADOS
  bool _isSearching = false;
  bool _selectAll = false;

  // SEGUIMIENTO DE SELECCIONADOS
  // ESTE LISTADO AYUDA A SINCRONIZAR CONTADORES VISUALES Y ACCIONES EN MASA
  int _selectedCount = 0;
  final List<Book> _selectedBooks = [];
  List<Book> get selectedBooks => _selectedBooks;

  //=========================== ACTUALIZA CONTADOR ===========================//
  // ACTUALIZA EL TOTAL DE ELEMENTOS SELECCIONADOS Y NOTIFICA AL PADRE
  // PROPÓSITO: MANTENER LA INTERFAZ SINCRONIZADA Y OFRECER FEEDBACK INMEDIATO
  void _updateSelectedCount() {
    if (mounted) {
      setState(() {
        _selectedBooks
          ..clear()
          ..addAll(_allBooks.where((b) => b.selected));

        _selectedCount = _selectedBooks.length;
      });
    }

    widget.onSelectionChanged?.call(_selectedCount);
  }

  //=========================== RESULTADOS DE BÚSQUEDA ===========================//
  // MANEJA LOS RESULTADOS GENERADOS POR EL WIDGET DE BÚSQUEDA
  // NARRATIVA: CUANDO EL USUARIO ES BUSCADOR, LA INTERFAZ RESPONDE MOSTRANDO UN CONJUNTO
  void _handleSearchResults(List<Book> results) {
    setState(() {
      _filteredBooks = results;
      _isSearching =
          results.isNotEmpty || widget.searchController.text.isNotEmpty;
      _currentPage = 0; // REINICIA LA PAGINACIÓN PARA EVITAR SALTOS CONFUSOS
    });
  }

  //=========================== CELDAS CLICKABLE ===========================//
  // CREA UNA CELDA QUE RESPONDE A CLICKS PARA ABRIR EL DETALLE DEL LIBRO
  // DISEÑO: USAR CURSOR DE MANO Y GESTO DE TAP PARA REFORZAR INTERACTIVIDAD
  Widget _buildClickableCell(Widget child, Book book) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onBookSelected(book),
        child: SizedBox(width: double.infinity, height: double.infinity, child: child),
      ),
    );
  }

  //=========================== TEXTO PARA CELDAS ===========================//
  // ESTILIZA Y ACOMODA TEXTO DENTRO DE LA TABLA
  // VISUAL: TEXTO EN COLOR BLANCO PARA CONTRASTE SOBRE EL FONDO OSCURO DE LA TABLA
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
    final columnWidths = <double>[50, 70, 320, 320, 90, 320];

    //=========================== PANEL SUPERIOR ===========================//
    // CONTIENE BÚSQUEDA, FILTROS Y CONTROLES DE ORDENAMIENTO
    // PROPÓSITO EMOCIONAL: PROVEER UN ENTORNO CALMADO PARA EXPLORAR EL INVENTARIO
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

          // BOTÓN DE FILTRO (AÚN SIN IMPLEMENTAR)
          // COMPORTAMIENTO FUTURO: ABRIRÁ UN PANEL CON OPCIONES PARA RESTRINGIR LA LISTA
          ActionButton(
            icon: Icons.filter_list,
            text: 'Filtrar',
            type: ActionType.secondary,
            onPressed: () {},
          ),

          const SizedBox(width: 12),

          // BOTÓN DE ORDENAMIENTO (AÚN SIN IMPLEMENTAR)
          // USO PREVISTO: PERMITIR ORDENAR POR TÍTULO, AUTOR O STOCK
          ActionButton(
            icon: Icons.sort,
            text: 'Ordenar',
            type: ActionType.secondary,
            onPressed: () {},
          ),
        ],
      );
    }

    //=========================== STREAM BUILDER ===========================//
    // ESCUCHA ACTUALIZACIONES EN LA BASE DE DATOS (FIRESTORE)
    // NARRATIVA: LA INTERFAZ SE MANTIENE VIVA, REFLEJANDO CAMBIOS EN TIEMPO REAL
    return StreamBuilder<List<Book>>(
      stream: widget.viewModel.getBooksStream(),
      builder: (context, snapshot) {
        //=========================== CUANDO NO HAY DATOS ===========================//
        // MUESTRA UNA TABLA VACÍA MIENTRAS SE CARGAN LOS DATOS
        if (!snapshot.hasData) {
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          );
        }

        //=========================== RESTAURA SELECCIONES ANTERIORES ===========================//
        // LÓGICA: CONSERVAR LA SELECCIÓN DEL USUARIO ENTRE REFRESCOS
        final previousSelections = {
          for (var b in _allBooks.where((b) => b.selected)) b.id: true,
        };

        _allBooks = snapshot.data ?? [];

        for (var book in _allBooks) {
          if (previousSelections.containsKey(book.id)) {
            book.selected = true;
          }
        }

        // DETERMINA SI SE USA BÚSQUEDA O LISTA COMPLETA
        List<Book> booksToShow = _isSearching ? _filteredBooks : _allBooks;

        //=========================== TABLA VACÍA ===========================//
        // SI NO HAY LIBROS, MOSTRAR UNA TABLA SIN FILAS
        if (_allBooks.isEmpty || (_isSearching && booksToShow.isEmpty)) {
          return CustomTable(
            headers: _buildHeaders(false),
            rows: const [],
            width: 1200,
            columnWidths: columnWidths,
            topWidget: buildTopWidget(),
          );
        }

        //=========================== MANEJO DE PAGINACIÓN ===========================//
        final startIndex = _currentPage * _booksPerPage;
        final endIndex =
            (startIndex + _booksPerPage).clamp(0, booksToShow.length);
        final books = booksToShow.sublist(startIndex, endIndex);

        // ACTUALIZA CONTADOR TRAS REFRESCAR UI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSelectedCount();
        });

        // VERIFICA SI TODOS EN LA PÁGINA ESTÁN SELECCIONADOS
        _selectAll = books.isNotEmpty && books.every((b) => b.selected == true);

        //=========================== TABLA PRINCIPAL ===========================//
        // RENDERIZA FILAS, CABECERAS Y CONTROLES DE PAGINACIÓN
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //=========================== CONTADOR DE SELECCIONADOS ===========================//
              // MOSTRAR CUÁNTOS ELEMENTOS ESTÁN SELECCIONADOS PARA OFRECER FEEDBACK
              if (_selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
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

              //=========================== RENDER DE FILAS ===========================//
              // CADA FILA REPRESENTA UN LIBRO; LOS ELEMENTOS SON INTERACTIVOS
              CustomTable(
                headers: _buildHeaders(true),
                rows: books.map((book) {
                  return [
                    //=========================== CHECKBOX INDIVIDUAL ===========================//
                    // ANIMACIÓN CORTA PARA REFLEJAR CAMBIOS DE SELECCIÓN (200MS)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        key: ValueKey(book.selected),
                        icon: Icon(
                          book.selected
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: book.selected
                              ? const Color(0xFF1C2532) // COLOR VERDE OSCURO PARA ESTADO ACTIVO
                              : Colors.white, // TEXTO BLANCO PARA FONDO OSCURO
                        ),
                        onPressed: () {
                          setState(() {
                            book.selected = !book.selected;
                          });

                          _updateSelectedCount();
                        },
                      ),
                    ),

                    //=========================== IMAGEN DE PORTADA ===========================//
                    // FOTOGRAFÍA DEL LIBRO CON BORDE REDONDEADO PARA SUAVIZAR LA APARIENCIA
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
                                    Image.asset('assets/images/sinportada.png',
                                        height: 50, width: 100),
                              )
                            : Image.asset('assets/images/sinportada.png',
                                height: 50, width: 100),
                      ),
                      book,
                    ),

                    //=========================== TEXTO DE COLUMNAS ===========================//
                    // TÍTULO, AUTOR, STOCK Y ÁREA. CADA CELDA ES CLICKABLE PARA NAVEGAR.
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

              //=========================== RESULTADOS DE BÚSQUEDA ===========================//
              // INDICADOR QUE MUESTRA CUÁNTOS RESULTADOS COINCIDEN CON LA BÚSQUEDA
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
              // MUESTRA CONTROLES DE NAVEGACIÓN ENTRE PÁGINAS SI APLICA
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

  //=========================== CABECERAS DE TABLA ===========================//
  // GENERA LAS CABECERAS Y MANEJA EL SELECT-ALL
  // NARRATIVA: LA CABECERA DA CONTEXTO A CADA COLUMNA Y OFRECE ACCIONES GLOBALES
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

                  // APLICA SELECCIÓN MASIVA
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
}
