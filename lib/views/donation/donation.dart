import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== VIEWMODEL ===========================//
import '../../viewmodels/donation/donation_vm.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== SUBCOMPONENTES ===========================//
import 'donation_table.dart';
import '../basic/import/import.dart';
import '../basic/export/export.dart';

//=========================== WIDGET PRINCIPAL DE DONACIONES ===========================//
class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

//=========================== ESTADO DE LA PÁGINA ===========================//
class _DonationsPageState extends State<DonationsPage> {
  final DonationsViewModel _viewModel = DonationsViewModel();
  final TextEditingController _searchController = TextEditingController();

  //=========================== BUILD PRINCIPAL ===========================//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //=========================== CABECERA DE PÁGINA ===========================//
            PageHeader(
              title: 'Donaciones',
              buttons: [
                HeaderButton(
                  icon: CupertinoIcons.qrcode_viewfinder,
                  text: 'Generar QRs',
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
                  text: 'Agregar donacion',
                  onPressed: () {
                    // Aquí puedes abrir un diálogo para agregar nueva donación
                  },
                  type: ActionType.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            //=========================== TABLA DE DONACIONES ===========================//
            Expanded(
              child: DonationsTable(
                viewModel: _viewModel,
                searchController: _searchController,
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
