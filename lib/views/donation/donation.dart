import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// VIEWMODELS
import '../../viewmodels/donation/donation_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

// COMPONENTES
import '../basic/export/download_dialog.dart';
import '../basic/import/import.dart';

// WIDGETS REUSABLES
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

// TABLA
import 'donation_table.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final DonationsViewModel _viewModel = DonationsViewModel();
  final TextEditingController _searchController = TextEditingController();
  final ExportViewModel _exportVM = ExportViewModel();

  // KEY PARA ACCEDER A LA TABLA
  final GlobalKey<DonationTableState> _tableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Donaciones',
              buttons: [
                HeaderButton(
                  icon: CupertinoIcons.qrcode_viewfinder,
                  text: 'Generar QRs',
                  onPressed: () {},
                  type: ActionType.secondary,
                ),

                // EXPORTAR
                HeaderButton(
                  icon: CupertinoIcons.arrow_down_circle,
                  text: 'Exportar',
                  onPressed: () async {
                    final selectedCount =
                        _tableKey.currentState?.selectedDonations.length ?? 0;

                    final option = await mostrarDialogoDescarga(
                      context,
                      totalItems: _viewModel.donationsCount,
                      selectedItems: selectedCount,
                      entityName: 'donaciones',
                    );

                    if (option == null) return;

                    if (option == 'all') {
                      final allData = _viewModel.getAllDonationsAsMap();

                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: allData,
                        fileName: 'donaciones_completas',
                        context: context,
                      );
                    } else if (option == 'selected') {
                      final selected =
                          _tableKey.currentState?.selectedDonations ?? [];

                      if (selected.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('No hay donaciones seleccionadas')),
                        );
                        return;
                      }

                      final data =
                          _viewModel.getSelectedDonationsAsMap(selected);

                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: data,
                        fileName: 'donaciones_seleccionadas',
                        context: context,
                      );
                    }
                  },
                  type: ActionType.secondary,
                ),

                HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const ImportadorCSV(),
                    );
                  },
                  type: ActionType.secondary,
                ),

                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar donación',
                  onPressed: () {},
                  type: ActionType.primary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: DonationsTable(
                key: _tableKey,
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
