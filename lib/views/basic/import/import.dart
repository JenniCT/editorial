import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../viewmodels/stock/import_vm.dart';

class ImportadorCSV extends StatefulWidget {
  const ImportadorCSV({super.key});

  @override
  State<ImportadorCSV> createState() => _ImportadorCSVState();
}

class _ImportadorCSVState extends State<ImportadorCSV> {
  final ImportadorCSVViewModel _vm = ImportadorCSVViewModel();

  @override
  Widget build(BuildContext context) {
    final previewRows = _vm.datosCSV ?? [];

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
                    'Importar libros desde CSV',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (previewRows.isNotEmpty)
                            Row(
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.upload_file, size: 20),
                                    label: const Text(
                                      'Seleccionar archivo CSV',
                                      style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2D4A91),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 18),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      elevation: 6,
                                    ),
                                    onPressed: () async {
                                      await _vm.importarCSV();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 250,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.cloud_upload, size: 20),
                                    label: Text(
                                      _vm.loading ? 'Subiendo...' : 'Subir datos',
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
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
                                            setState(() {
                                              _vm.loading = true;
                                              _vm.cancelarImportacion = false;
                                            });
                                            await _vm.subirDatosAFirestore(context);
                                            setState(() {
                                              _vm.loading = false;
                                            });
                                          },
                                  ),
                                ),
                              ],
                            )
                          else
                            Center(
                              child: SizedBox(
                                width: 250,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.upload_file, size: 20),
                                  label: const Text(
                                    'Seleccionar archivo CSV',
                                    style: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2D4A91),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    elevation: 6,
                                  ),
                                  onPressed: () async {
                                    await _vm.importarCSV();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (_vm.error != null) ...[
                            Text(
                              _vm.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (previewRows.isNotEmpty) ...[
                            Text(
                              'Vista previa (primeras 20 filas):',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                itemCount: previewRows.length > 20
                                    ? 20
                                    : previewRows.length,
                                itemBuilder: (context, index) {
                                  final fila = previewRows[index];
                                  final texto =
                                      fila.map((c) => (c ?? '').toString()).join(' , ');
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
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // --- Botón de detener importación, abajo ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_vm.loading)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _vm.cancelarImportacion = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF05B54),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Detener importación',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
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
