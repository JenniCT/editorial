import 'package:flutter/material.dart';
import '../../viewmodels/book/book_vm.dart';
import '../../models/history_bk.dart';

class HistorialView extends StatelessWidget {
  final String idLibro;
  const HistorialView({required this.idLibro, super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = BookViewModel();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ediciones'),
      ),
      body: StreamBuilder<List<Historial>>(
        stream: viewModel.getHistorialPorLibro(idLibro),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final historial = snapshot.data ?? [];

          // Construir filas
          final List<DataRow> rows = [];

          for (final item in historial) {
            item.cambios.forEach((campo, cambio) {
              rows.add(
                DataRow(cells: [
                  DataCell(Text(
                    item.fechaEdicion.toString(),
                    style: const TextStyle(fontSize: 12),
                  )),
                  DataCell(Text(
                    item.editadoPor,
                    style: const TextStyle(fontSize: 12),
                  )),
                  DataCell(Text(
                    campo,
                    style: const TextStyle(fontSize: 12),
                  )),
                  DataCell(Text(
                    cambio.toString(),
                    style: const TextStyle(fontSize: 12),
                  )),
                ]),
              );
            });
          }
          
          if (rows.isEmpty) {
            rows.add(
              const DataRow(cells: [
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
              ]),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Usuario')),
                DataColumn(label: Text('Campo')),
                DataColumn(label: Text('Cambio')),
              ],
              rows: rows,
            ),
          );
        },
      ),
    );
  }
}