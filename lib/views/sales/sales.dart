import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== VISTAMODELO ===========================//
import '../../viewmodels/market/sales_vm.dart';

//=========================== WIDGETS REUTILIZABLES ===========================//
import '../../widgets/modules/page_header.dart';
import '../../widgets/modules/header_button.dart';

//=========================== SUBCOMPONENTES ===========================//
import 'sales_table.dart';
import '../import/import.dart';
import '../export/export.dart';

//=========================== WIDGET PRINCIPAL DE LA PÁGINA DE VENTAS ===========================//
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

//=========================== ESTADO DE LA PÁGINA ===========================//
class _SalesPageState extends State<SalesPage> {
  final SalesViewModel _viewModel = SalesViewModel();
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
                  onPressed: () {
                    // Aquí puedes abrir un diálogo para agregar nueva venta si lo deseas
                  },
                  type: ActionType.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            //=========================== TABLA DE VENTAS ===========================//
            Expanded(
              child: SalesTable(
                viewModel: _viewModel,
                searchController: _searchController,
                onSaleSelected: (sale) {
                  // Mostrar detalle de la venta en un diálogo
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Detalle de la venta'),
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
