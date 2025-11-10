import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// MODELO
import '../../models/book_m.dart';

// VISTAMODELO
import '../../viewmodels/acervo/acervo_vm.dart';

// VISTAS SECUNDARIAS
import '../book/details_bk.dart';
import '../acervo/add_acervo.dart';

// WIDGETS
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

// SUBCOMPONENTES
import 'acervo_table.dart';

class AcervoPage extends StatefulWidget {
  final Function(Book) onAcervoSelected;

  const AcervoPage({required this.onAcervoSelected, super.key});

  @override
  State<AcervoPage> createState() => _AcervoPageState();
}

class _AcervoPageState extends State<AcervoPage> {
  final AcervoViewModel _viewModel = AcervoViewModel();
  final TextEditingController _searchController = TextEditingController();

  Book? _selectedBook;
  bool _showingDetail = false;

  void _handleBookSelection(Book book) {
    setState(() {
      _selectedBook = book;
      _showingDetail = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // MOSTRAR DETALLE
    if (_showingDetail && _selectedBook != null) {
      return DetalleLibroPage(
        book: _selectedBook!,
        onBack: () => setState(() => _showingDetail = false),
        key: const ValueKey('DetalleLibro'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA CON ACCIONES
            PageHeader(
              title: 'Acervo',
              buttons: [
                HeaderButton(
                  icon: Icons.filter_list,
                  text: 'Filtrar',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),
                HeaderButton(
                  icon: Icons.download,
                  text: 'Exportar',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),
                HeaderButton(
                  icon: Icons.upload,
                  text: 'Importar',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),
                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar libro',
                  onPressed: () => showAddAcervoDialog(
                    context,
                    (newBook) => _viewModel.addAcervo(newBook, context),
                  ),
                  type: ActionType.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // TABLA DE ACERVO
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
}
