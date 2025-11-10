import 'dart:ui';
import 'package:flutter/material.dart';
import '../../viewmodels/stock/export_vm.dart';

class ExportadorCSV extends StatefulWidget {
  const ExportadorCSV({super.key});

  @override
  State<ExportadorCSV> createState() => _ExportadorCSVState();
}

class _ExportadorCSVState extends State<ExportadorCSV> {
  final ExportadorCSVViewModel _vm = ExportadorCSVViewModel();

  @override
  void initState() {
    super.initState();
    cargarLibros();
  }

  Future<void> cargarLibros() async {
    await _vm.obtenerLibros();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final previewRows = _vm.libros?.take(20).toList() ?? [];

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: previewRows.isNotEmpty ? 600 : 400,
              height: previewRows.isNotEmpty ? 500 : 200,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(19, 38, 87, 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color.fromRGBO(47, 65, 87, 0.3)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Exportar libros a CSV',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _vm.loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                if (_vm.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      _vm.error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                if (previewRows.isNotEmpty)
                                  SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      itemCount: previewRows.length,
                                      itemBuilder: (context, index) {
                                        final book = previewRows[index];
                                        final texto =
                                            '${book.titulo} - ${book.autor}';
                                        return ListTile(
                                          dense: true,
                                          tileColor:
                                              const Color.fromRGBO(255, 255, 255, 0.05),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          title: Text(
                                            texto,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          leading: Text(
                                            '$index',
                                            style: const TextStyle(
                                                color: Colors.white70, fontSize: 16),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  const Center(
                                    child: Text(
                                      'No hay libros para mostrar',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Exportar CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      onPressed: _vm.loading
                          ? null
                          : () async {
                              await _vm.exportarCSV(context);
                              setState(() {});
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
