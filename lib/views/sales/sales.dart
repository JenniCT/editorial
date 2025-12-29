import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== VISTAMODELOS ===========================//
import '../../viewmodels/market/sales_vm.dart';
import '../../viewmodels/docs/export_vm.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== SUBCOMPONENTES ===========================//
import 'sales_table.dart';
import '../basic/import/import.dart';
import '../basic/export/download_dialog.dart';

//=========================== WIDGET PRINCIPAL DE LA PÁGINA DE VENTAS ===========================//
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

//=========================== ESTADO DE LA PÁGINA ===========================//
class _SalesPageState extends State<SalesPage> {
  final SalesViewModel _viewModel = SalesViewModel();
  final ExportViewModel _exportVM = ExportViewModel();   // <-- AÑADIDO
  final TextEditingController _searchController = TextEditingController();

  // ACCESO AL ESTADO DE LA TABLA (NECESARIO PARA EXPORTAR SELECCIONADOS)
  final GlobalKey<SalesTableState> _tableKey = GlobalKey<SalesTableState>();

  // CONTADOR DE SELECCIONADOS
  int selectedSalesCount = 0;

  @override
  Widget build(BuildContext context) {
    final int totalSalesCount = _viewModel.salesCount;  
    // **ASEGÚRATE DE TENER ESTE GETTER EN SalesViewModel**

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //=========================== CABECERA DE PÁGINA ===========================//
            PageHeader(
              title: 'Ventas',
              buttons: [
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
                      totalItems: totalSalesCount,
                      selectedItems: selectedSalesCount,
                      entityName: 'ventas',
                    );

                    if (option == null) return;

                    // EXPORTAR TODOD
                    if (option == 'all') {
                      final allSales = await _viewModel.getAllSalesAsMap();

                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: allSales,
                        fileName: 'ventas_completas',
                        context: context,
                      );
                    }

                    // EXPORTAR SOLO SELECCIONADOS
                    else if (option == 'selected') {
                      final selectedSales =
                          _tableKey.currentState?.selectedSales ?? [];

                      if (selectedSales.isEmpty) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('No hay ventas seleccionadas para exportar')),
                        );
                        return;
                      }

                      final selectedData =
                          await _viewModel.getSelectedSalesAsMap(selectedSales);

                      if (!context.mounted) return;

                      await _exportVM.exportToExcel(
                        data: selectedData,
                        fileName: 'ventas_seleccionadas',
                        context: context,
                      );
                    }
                  },
                  type: ActionType.secondary,
                ),

                //==================== IMPORTAR ====================//
                HeaderButton(
                  icon: CupertinoIcons.arrow_up_circle,
                  text: 'Importar',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ImportadorCSV(),
                  ),
                  type: ActionType.secondary,
                ),

                //==================== AGREGAR ====================//
                HeaderButton(
                  icon: CupertinoIcons.add_circled_solid,
                  text: 'Agregar ventas',
                  onPressed: () {},
                  type: ActionType.primary,
                ),
              ],
            ),

            const SizedBox(height: 20),

            //=========================== TABLA DE VENTAS ===========================//
            Expanded(
              child: SalesTable(
                key: _tableKey,
                viewModel: _viewModel,
                searchController: _searchController,

                // ACTUALIZA CONTADOR DE SELECCIONADOS
                onSelectionChanged: (count) {
                  setState(() => selectedSalesCount = count);
                },

                onSaleSelected: (sale) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Detalle de la venta'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Título: ${sale.titulo}'),
                          Text('Cantidad: ${sale.cantidad}'),
                          Text('Total: ${sale.total.toStringAsFixed(2)}'),
                          Text('Fecha: ${sale.fecha.day}/${sale.fecha.month}/${sale.fecha.year}'),
                          Text('Lugar: ${sale.lugar}'),
                          Text('Usuario: ${sale.userEmail}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
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
