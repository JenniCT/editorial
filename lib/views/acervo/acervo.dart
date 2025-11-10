import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== MODELOS ===========================//
import '../../models/book_m.dart';

//=========================== VISTAMODELO ===========================//
import '../../viewmodels/acervo/acervo_vm.dart';

//=========================== VISTAS SECUNDARIAS ===========================//
import '../book/details_bk.dart';
import '../acervo/add_acervo.dart';
import '../import/import.dart';
import '../export/export.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== SUBCOMPONENTES ===========================//
import 'acervo_table.dart';

//=========================== WIDGET PRINCIPAL DE LA PÁGINA DE ACERVO ===========================//
class AcervoPage extends StatefulWidget {
  final Function(Book) onAcervoSelected;

  const AcervoPage({required this.onAcervoSelected, super.key});

  @override
  State<AcervoPage> createState() => _AcervoPageState();
}

//=========================== ESTADO DE LA PÁGINA ===========================//
class _AcervoPageState extends State<AcervoPage> {
  final AcervoViewModel _viewModel = AcervoViewModel();
  final TextEditingController _searchController = TextEditingController();

  Book? _selectedBook; // LIBRO SELECCIONADO ACTUAL
  bool _showingDetail = false; // INDICA SI SE MUESTRA LA PÁGINA DE DETALLE

  //=========================== MÉTODO DE SELECCIÓN DE LIBRO ===========================//
  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }

  //=========================== BUILD PRINCIPAL ===========================//
  @override
  Widget build(BuildContext context) {
    //=========================== VISTA DE DETALLE ===========================//
    if (_showingDetail && _selectedBook != null) {
      return DetalleLibroPage(
        book: _selectedBook!,
        onBack: () => setState(() => _showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }

    //=========================== VISTA PRINCIPAL DE ACERVO ===========================//
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //=========================== CABECERA DE PÁGINA ===========================//
            PageHeader(
              title: 'Acervo',
              buttons: [
                HeaderButton(
                  icon: CupertinoIcons.qrcode,
                  text: 'Generar Qrs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),
                HeaderButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ExportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),
                HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ImportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),
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
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
