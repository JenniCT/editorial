import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
// MODELO CENTRAL DE IDENTIDAD DEL ACERVO,
// REPRESENTA CADA LIBRO QUE COMPONE LA COLECCIÓN.
import '../../models/book_m.dart';

//=========================== VISTAMODELOS ===========================//
// VISTAMODEL QUE GESTIONA ACERVO: LECTURA, BÚSQUEDA,
// SELECCIÓN, EDICIÓN Y EXPORTACIONES BASE.
import '../../viewmodels/acervo/acervo_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
// COMPLEMENTOS QUE REFUERZAN FLUJOS DE DETALLE, IMPORTACIÓN Y CREACIÓN.
import '../book/details_bk.dart';
import '../acervo/add_acervo.dart';
import '../basic/export/download_dialog.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
// COMPONENTES DE IDENTIDAD VISUAL: ENCABEZADOS Y ACCIONES SUPERIORES.
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== TABLA DE ACERVO ===========================//
// CORAZÓN VISUAL DE ESTA PÁGINA: BUSCAR, PAGINAR, SELECCIONAR Y VER LISTADOS.
import 'acervo_table.dart';


//===============================================================//
//                        ACERVO PAGE
//===============================================================//
// ESTA PÁGINA MANTIENE TODA LA NARRATIVA OPERATIVA DEL ACERVO:
// SELECCIÓN, EXPORTACIÓN, IMPORTACIÓN, DETALLE Y CREACIÓN.
class AcervoPage extends StatefulWidget {
  final Function(Book) onAcervoSelected;

  const AcervoPage({required this.onAcervoSelected, super.key});

  @override
  State<AcervoPage> createState() => _AcervoPageState();
}

class _AcervoPageState extends State<AcervoPage> {
  //=========================== CONTROLADORES Y ESTADOS ===========================//
  // VIEWMODEL DE ACERVO — FUENTE PRINCIPAL DE DATOS.
  final AcervoViewModel _viewModel = AcervoViewModel();

  // CONTROLADOR DEL BUSCADOR PARA UNA EXPERIENCIA SUAVE Y EXPRESIVA.
  final TextEditingController _searchController = TextEditingController();

  // VIEWMODEL DE EXPORTACIÓN — NARRATIVA COMPLEMENTARIA.
  final ExportViewModel _exportVM = ExportViewModel();

  // ACCESO DIRECTO AL ESTADO DE LA TABLA, NECESARIO PARA EXPORTAR.
  final GlobalKey<AcervoTableState> _tableKey = GlobalKey<AcervoTableState>();

  // SELECCIÓN ACTUAL PARA DETALLE.
  Book? _selectedBook;

  // BANDERA QUE INDICA SI SE MUESTRA DETALLE.
  bool _showingDetail = false;

  // CONTADOR DE SELECCIONADOS (SE ACTUALIZA DESDE LA TABLA).
  int selectedBooksCount = 0;


  //=========================== MANEJO DE SELECCIÓN INDIVIDUAL ===========================//
  // FUNCIÓN QUE TRANSICIONA HACIA LA EXPERIENCIA DE DETALLE.
  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    //=========================== CONDICIÓN PARA VISTA DETALLADA ===========================//
    if (_showingDetail && _selectedBook != null) {
      return DetalleLibroPage(
        book: _selectedBook!,
        onBack: () => setState(() => _showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }

    final int totalBooksCount = _viewModel.acervoBooksCount;

    //=========================== ESTRUCTURA PRINCIPAL ===========================//
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== ENCABEZADO DE PÁGINA ===========================//
            PageHeader(
              title: 'Acervo',
              buttons: [
                //==================== GENERAR QRS ====================//
                HeaderButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),

                //==================== EXPORTAR ====================//
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

                    // EXPORTAR TODOS
                    if (option == 'all') {
                      final allBooks = await _viewModel.getAllAcervoBooksAsMap();
                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: allBooks,
                        fileName: 'acervo_completo',
                        context: context,
                      );
                    }

                    // EXPORTAR SOLO SELECCIONADOS
                    else if (option == 'selected') {
                      final selectedBooks = _tableKey.currentState?.selectedBooks ?? [];

                      if (selectedBooks.isEmpty) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No hay libros seleccionados para exportar')),
                        );
                        return;
                      }

                      final selectedData =
                          await _viewModel.getSelectedBooksAsMap(selectedBooks);

                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: selectedData,
                        fileName: 'acervo_seleccionado',
                        context: context,
                      );
                    }
                  },
                  type: ActionType.secondary,
                ),

                //==================== IMPORTAR ====================//
                /*HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ImportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),*/

                //==================== AGREGAR NUEVO ====================//
                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar acervo',
                  onPressed: () => showAddAcervoDialog(
                    context,
                    (newBook) => _viewModel.addAcervo(newBook, context),
                  ),
                  type: ActionType.primary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            //=========================== TABLA DE ACERVO ===========================//
            Expanded(
              child: AcervoTable(
                key: _tableKey,
                viewModel: _viewModel,
                searchController: _searchController,
                onBookSelected: _handleBookSelection,
                onSelectionChanged: (count) => setState(() => selectedBooksCount = count),
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
