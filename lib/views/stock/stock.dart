import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
// MODELOS DE DATOS QUE REPRESENTAN LIBROS
import '../../models/book_m.dart';

//=========================== VISTAMODELO ===========================//
// VISTAMODELO QUE GESTIONA EL ESTADO Y LÓGICA DE NEGOCIO DE LOS LIBROS
import '../../viewmodels/book/book_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
// PÁGINAS DE DETALLE, IMPORTACIÓN, EXPORTACIÓN Y ADICIÓN DE LIBROS
import 'add_bk.dart';
import '../book/details_bk.dart';
import '../import/import.dart';
import '../export/export.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
// CABECERAS, BOTONES Y ELEMENTOS DE INTERFAZ PARA CONSISTENCIA VISUAL
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== SUBCOMPONENTES ===========================//
// TABLA DE INVENTARIO REUTILIZABLE
import 'stock_table.dart';

//=========================== WIDGET PRINCIPAL DE LA PÁGINA DE INVENTARIO ===========================//
// MUESTRA LA LISTA COMPLETA DE LIBROS, ACCIONES Y DETALLE INDIVIDUAL
class InventarioPage extends StatefulWidget {
  final Function(Book) onBookSelected;

  const InventarioPage({required this.onBookSelected, super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

//=========================== ESTADO DE LA PÁGINA ===========================//
// CONTROLA SELECCIÓN DE LIBROS, VISUALIZACIÓN DE DETALLES Y BÚSQUEDA
class _InventarioPageState extends State<InventarioPage> {
  final BookViewModel _viewModel = BookViewModel();
  final TextEditingController _searchController = TextEditingController();

  Book? _selectedBook; // LIBRO SELECCIONADO ACTUAL
  bool _showingDetail = false; // INDICA SI SE MUESTRA LA PÁGINA DE DETALLE

  //=========================== MÉTODO DE SELECCIÓN DE LIBRO ===========================//
  // ACTUALIZA EL ESTADO PARA MOSTRAR DETALLE DEL LIBRO SELECCIONADO
  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }

  //=========================== BUILD PRINCIPAL ===========================//
  // DECIDE SI MOSTRAR DETALLE O LISTA DE INVENTARIO
  @override
  Widget build(BuildContext context) {
    //=========================== VISTA DE DETALLE ===========================//
    // SI HAY UN LIBRO SELECCIONADO, SE MUESTRA SU DETALLE
    if (_showingDetail && _selectedBook != null) {
      return DetalleLibroPage(
        book: _selectedBook!,
        onBack: () => setState(() => _showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }

    //=========================== VISTA PRINCIPAL DE INVENTARIO ===========================//
    return Scaffold(
      backgroundColor: Colors.transparent, // FONDO TRANSPARENTE PARA ESTILO ADAPTIVO
      body: Padding(
        padding: const EdgeInsets.all(24.0), // ESPACIADO GENERAL PARA LEGIBILIDAD
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //=========================== CABECERA DE PÁGINA ===========================//
            // MUESTRA TÍTULO Y ACCIONES RÁPIDAS DEL USUARIO
            PageHeader(
              title: 'Libros',
              buttons: [
                // BOTÓN PARA GENERAR CÓDIGOS QR
                HeaderButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),
                // BOTÓN PARA EXPORTAR CSV
                HeaderButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ExportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),
                // BOTÓN PARA IMPORTAR CSV
                HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ImportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),
                // BOTÓN PRINCIPAL PARA AGREGAR NUEVO LIBRO
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

            //=========================== TABLA DE INVENTARIO ===========================//
            // MUESTRA LA LISTA DE LIBROS CON BÚSQUEDA, SELECCIÓN Y PAGINACIÓN
            Expanded(
              child: InventarioTable(
                viewModel: _viewModel,
                searchController: _searchController,
                onBookSelected: _handleBookSelection,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //=========================== DISPOSICIÓN DE RECURSOS ===========================//
  // LIMPIA CONTROLADORES AL DESTRUIR EL WIDGET
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
