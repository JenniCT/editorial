import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// VISTAMODELO
import '../../viewmodels/market/sales_vm.dart';

// WIDGETS
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

// SUBCOMPONENTES
import 'sales_table.dart';
import '../import/import.dart';
import '../export/export.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SalesViewModel _viewModel = SalesViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA CON ACCIONES
            PageHeader(
              title: 'Ventas',
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
                  text: 'Agregar ventas',
                  onPressed: () {},
                  type: ActionType.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // TABLA DE VENTAS
            Expanded(
              child: SalesTable(
                viewModel: _viewModel,
                searchController: _searchController,
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
