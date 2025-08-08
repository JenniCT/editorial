import 'package:flutter/material.dart';
import '../models/bookdata.dart';

class DetalleLibroPage extends StatelessWidget {
  final BookData book;
  final VoidCallback onBack;

  const DetalleLibroPage({
    required this.book,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Detalle del Libro'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📘 Tarjeta del libro
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Portada
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.imageUrl,
                            height: 500,
                            width: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 32),

                        // 📋 Detalles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                book.subtitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 📊 Tabla de atributos
                              Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(160),
                                  1: FlexColumnWidth(),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  _buildRow('Autor', book.author),
                                  _buildRow('Editorial', book.editorial),
                                  _buildRow('Colección', book.collection),
                                  _buildRow('Año', book.year),
                                  _buildRow('ISBN', book.isbn),
                                  _buildRow('Edición', book.edition),
                                  _buildRow('Ejemplares', book.copies),
                                  _buildRow('Precio', book.price),
                                  _buildRow('Formato', book.format),
                                ],
                              ),
                            
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),

                          // 🎯 Botones alineados verticalmente dentro de la tarjeta
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildActionButton(Icons.edit, 'Editar'),
                              const SizedBox(height: 12),
                              _buildActionButton(Icons.volunteer_activism, 'Donar'),
                              const SizedBox(height: 12),
                              _buildActionButton(Icons.attach_money, 'Vender'),
                              const SizedBox(height: 12),
                              _buildActionButton(Icons.remove_circle, 'Dar de baja'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32), 
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value),
        ),
      ],
    );
  }
}

Widget _buildActionButton(IconData icon, String label, {Color? color}) {
  return SizedBox(
    width: 160,
    height: 48,
    child: ElevatedButton.icon(
      onPressed: () {}, // Acción pendiente
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        textStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}