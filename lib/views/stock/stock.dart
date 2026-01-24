import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
// SE IMPORTAN LOS MODELOS QUE REPRESENTAN LA IDENTIDAD DE CADA LIBRO,
// BASE ESTRUCTURAL DE LA NARRATIVA DEL INVENTARIO.
import '../../models/book_m.dart';

//=========================== VISTAMODELOS ===========================//
// ESTOS VIEWMODELS ORQUESTAN LA LÓGICA, MANTENIENDO COHERENCIA
// ENTRE LA INTERFAZ Y LOS DATOS, CON UN TONO HUMANO Y ORDENADO.
import '../../viewmodels/book/book_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
// ESTAS PANTALLAS COMPLEMENTAN LA EXPERIENCIA GENERAL, OFRECIENDO
// FLUJOS NATURALES COMO AÑADIR, IMPORTAR O CONSULTAR DETALLES.
import 'add_bk.dart';
import '../book/details_bk.dart';
import '../basic/export/download_dialog.dart';

//=========================== WIDGETS ===========================//
// ESTOS COMPONENTES APOYAN LA EXPERIENCIA DE IDENTIDAD VISUAL,
// MANTENIENDO UNA PRESENTACIÓN COHERENTE Y ORIENTADA AL USUARIO.
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== TABLA DE INVENTARIO ===========================//
// ESTE WIDGET REPRESENTA EL CORAZÓN VISUAL DEL INVENTARIO,
// PERMITIENDO CONSULTA Y SELECCIÓN DE MANERA ORDENADA Y ARMONIOSA.
import 'stock_table.dart';

//===============================================================//
//                      INVENTARIO PAGE
//===============================================================//
// ESTA PÁGINA FUNGE COMO CENTRO OPERATIVO DEL INVENTARIO.
// SE DISEÑA PARA OFRECER UNA EXPERIENCIA CÁLIDA, CLARA Y PROFESIONAL,
// DONDE LOS LIBROS PUEDAN CONSULTARSE, FILTRARSE Y GESTIONARSE.
class InventarioPage extends StatefulWidget {
  final Function(Book) onBookSelected;

  const InventarioPage({required this.onBookSelected, super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  //=========================== CONTROLADORES Y ESTADOS ===========================//
  // VIEWMODEL CENTRAL PARA GESTIONAR LIBROS, SOSTENIENDO LA LÓGICA PRINCIPAL.
  final BookViewModel _viewModel = BookViewModel();

  // CONTROLADOR DEL BUSCADOR, PERMITE UNA EXPERIENCIA RESPONSIVA Y HUMANA.
  final TextEditingController _searchController = TextEditingController();

  // VIEWMODEL DE EXPORTACIÓN, CREADO PARA OFRECER UNA NARRATIVA COMPLETA.
  final ExportViewModel _exportVM = ExportViewModel();

  // CLAVE PARA ACCEDER AL ESTADO DE LA TABLA Y SUS SELECCIONES.
  final GlobalKey<InventarioTableState> _tableKey = GlobalKey<InventarioTableState>();

  // ESTADO DEL LIBRO SELECCIONADO PARA VISUALIZACIÓN DETALLADA.
  Book? _selectedBook;

  // BANDERA PARA MOSTRAR U OCULTAR LA PANTALLA DE DETALLE.
  bool _showingDetail = false;

  // CONTADOR DE SELECCIÓN PARA EXPORTACIONES Y ACCIONES CONTEXTUALES.
  int selectedBooksCount = 0;

  //=========================== MANEJO DE SELECCIÓN ===========================//
  // ESTA FUNCIÓN ABRE LA EXPERIENCIA DE DETALLE, GENERANDO UN PUENTE EMOCIONAL
  // ENTRE LA LISTA GENERAL Y LA IDENTIDAD INDIVIDUAL DEL LIBRO.
  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    //=========================== CONDICIÓN PARA VISTA DETALLADA ===========================//
    // CUANDO SE ESTÁ MOSTRANDO EL DETALLE, LA INTERFAZ PRIORITIZA
    // LA NARRATIVA INDIVIDUAL DEL LIBRO SOBRE LA VISTA GENERAL.
    if (_showingDetail && _selectedBook != null) {
      return DetalleLibroPage(
        book: _selectedBook!,
        onBack: () => setState(() => _showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }

    final int totalBooksCount = _viewModel.booksCount;

    //=========================== ESTRUCTURA PRINCIPAL ===========================//
    // SE EMPLEA UN SCAFFOLD LIMPIO Y TRANSPARENTE PARA RESPETAR
    // EL ESTILO GLOBAL DEL PROYECTO Y PERMITIR CAPAS VISUALES.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),

        //=========================== DISEÑO EN COLUMNAS ===========================//
        // LA ESTRUCTURA BUSCA OFRECER JERARQUÍA VISUAL, AGRUPANDO ENCABEZADO
        // Y TABLA DE MANERA NATURAL, APOYADA POR ESPACIADOS ARMÓNICOS.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== ENCABEZADO DE PÁGINA ===========================//
            // ESTE WIDGET DEFINE EL TONO EMOCIONAL Y OPERATIVO DEL INVENTARIO,
            // PRESENTANDO ACCIONES, TÍTULO Y NAVEGACIÓN SUPERIOR.
            PageHeader(
              title: 'Libros',
              buttons: [
                // ÍCONO DE GENERACIÓN DE CÓDIGOS QR — COMUNICA ACCIÓN MODERNA Y FUNCIONAL.
                HeaderButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),

                //==================== EXPORTAR ====================//
                // BOTÓN DE EXPORTACIÓN — COLOR NEUTRO QUE REFUERZA SU FUNCIÓN ANALÍTICA.
                HeaderButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',

                  // LÓGICA QUE ABRE EL DIÁLOGO DE DESCARGA Y EJECUTA EXPORTACIONES.
                  onPressed: () async {
                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: totalBooksCount,
                      selectedItems: selectedBooksCount,
                      entityName: 'libros',
                    );

                    if (option == null) return;

                    // EXPORTACIÓN DE TODOS LOS LIBROS ACTIVOS
                    if (option == 'all') {
                      final allBooks = await _viewModel.getAllBooksAsMap();
                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: allBooks,
                        fileName: 'libros_activos',
                        context: context,
                      );

                    // EXPORTACIÓN SOLO DE SELECCIONADOS
                    } else if (option == 'selected') {
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
                        fileName: 'libros_seleccionados',
                        context: context,
                      );
                    }
                  },
                  type: ActionType.secondary,
                ),

                //==================== IMPORTAR ====================//
                // ESTE BOTÓN INVITA A AÑADIR INFORMACIÓN EXTERNA, GENERANDO UNA
                // EXPERIENCIA DE CRECIMIENTO DEL INVENTARIO.
                /*HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ImportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),*/

                //==================== AGREGAR ====================//
                // BOTÓN PRINCIPAL — COLOR DIFERENCIADO PARA DESTACAR SU ROL CREATIVO.
                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar libro',

                  // DIÁLOGO PARA AGREGAR NUEVO LIBRO — EXPERIENCIA DE CREACIÓN.
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

            //=========================== TABLA DE INVENTARIO ===========================//
            // LA TABLA ES EL ESPACIO DONDE SE MATERIALIZA LA COLECCIÓN.
            // AQUÍ SE PERMITE BUSCAR, SELECCIONAR Y OBSERVAR PATRONES.
            Expanded(
              child: InventarioTable(
                key: _tableKey,
                viewModel: _viewModel,
                searchController: _searchController,

                // SELECCIÓN INDIVIDUAL PARA NAVEGAR A DETALLE.
                onBookSelected: _handleBookSelection,

                // CAMBIOS EN LA SELECCIÓN PARA EXPORTACIONES O ACCIONES MASIVAS.
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
    //=========================== LIMPIEZA DE RECURSOS ===========================//
    // SE DESCARTA EL CONTROLADOR PARA OFRECER UNA EXPERIENCIA LIMPIA Y RESPONSABLE.
    _searchController.dispose();
    super.dispose();
  }
}
