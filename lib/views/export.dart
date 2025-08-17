import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExportarCSVDialog extends StatelessWidget {
  const ExportarCSVDialog({super.key});

  Future<void> exportarCSV(List<List<dynamic>> data, String fileName) async {
    final csv = const ListToCsvConverter().convert(data);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName.csv';
    final file = File(path);

    await file.writeAsString(csv);
    print('Archivo guardado en: $path');
  }

  @override
  Widget build(BuildContext context) {
    final List<List<dynamic>> datosDeEjemplo = [
      ['Título', 'Autor', 'Editorial', 'Año'],
      ['Cien años de soledad', 'Gabriel García Márquez', 'Sudamericana', 1967],
      ['El Principito', 'Antoine de Saint-Exupéry', 'Reynal & Hitchcock', 1943],
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Exportar CSV', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Exporta tu inventario de libros a un archivo CSV.'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.download),
            label: Text('Guardar CSV'),
            onPressed: () async {
              await exportarCSV(datosDeEjemplo, 'inventario_libros');
              Navigator.pop(context); // Cierra el modal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Archivo CSV exportado exitosamente')),
              );
            },
          ),
        ],
      ),
    );
  }
}