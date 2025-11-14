import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
import '../../models/book_m.dart';

//=========================== VISTAMODELOS ===========================//
import '../../viewmodels/book/book_vm.dart';
import '../../viewmodels/basic/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
import 'add_bk.dart';
import '../book/details_bk.dart';
import '../basic/import/import.dart';
import '../basic/export/download_dialog.dart';

//=========================== WIDGETS ===========================//
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== TABLA DE INVENTARIO ===========================//
import 'stock_table.dart';

//===============================================================//
//                      INVENTARIO PAGE
//===============================================================//
class InventarioPage extends StatefulWidget {
  final Function(Book) onBookSelected;

  const InventarioPage({required this.onBookSelected, super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final BookViewModel _viewModel = BookViewModel();
  final TextEditingController _searchController = TextEditingController();
  final ExportViewModel _exportVM = ExportViewModel();

  // clave para acceder al estado de la tabla
  final GlobalKey<InventarioTableState> _tableKey = GlobalKey<InventarioTableState>();


  Book? _selectedBook;
  bool _showingDetail = false;
  int selectedBooksCount = 0;

  //=========================== SELECCIÓN ===========================//
  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingDetail && _selectedBook != null) {
      return DetalleLibroPage(
        book: _selectedBook!,
        onBack: () => setState(() => _showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }

    final int totalBooksCount = _viewModel.booksCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Libros',
              buttons: [
                HeaderButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),
                // ================== EXPORTAR ================== //
                HeaderButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () async {
                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: totalBooksCount,
                      selectedItems: selectedBooksCount,
                      entityName: 'libros',
                    );

                    if (option == null) return;

                    if (option == 'all') {
                      // 🔹 Exportar solo libros activos
                      final allBooks = await _viewModel.getAllBooksAsMap();
                      await _exportVM.exportToExcel(
                        data: allBooks,
                        fileName: 'libros_activos',
                        context: context,
                      );


                    } else if (option == 'selected') {
                      // 🔹 Exportar seleccionados desde la tabla
                      final selectedBooks = _tableKey.currentState?.selectedBooks ?? [];

                      if (selectedBooks.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No hay libros seleccionados para exportar')),
                        );
                        return;
                      }

                      final selectedData = await _viewModel.getSelectedBooksAsMap(selectedBooks);

                      await _exportVM.exportToExcel(
                        data: selectedData,
                        fileName: 'libros_seleccionados',
                        context: context,
                      );
                    }
                  },
                  type: ActionType.secondary,
                ),
                // ================== IMPORTAR ================== //
                HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ImportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),
                // ================== AGREGAR ================== //
                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar libro',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddBookDialog(
                      onAdd: (newBook) => _viewModel.addBook(newBook, context),
                    ),
                  ),
                  type: ActionType.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ================== TABLA ================== //
            Expanded(
              child: InventarioTable(
                key: _tableKey,
                viewModel: _viewModel,
                searchController: _searchController,
                onBookSelected: _handleBookSelection,
                onSelectionChanged: (count) {
                  setState(() => selectedBooksCount = count);
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
    _searchController.dispose();
    super.dispose();
  }
}
