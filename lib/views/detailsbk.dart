import 'package:flutter/material.dart';
import '../models/bookM.dart';

class DetalleLibroPage extends StatelessWidget {
  final Book book;
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
        title: const Text('Detalle del Libro'),
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
            // Tarjeta del libro con portada y detalles
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
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
                        // Portada del libro con placeholder si no hay imagen
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: book.imagenUrl != null && book.imagenUrl!.isNotEmpty
                              ? Image.network(
                                  book.imagenUrl!,
                                  height: 500,
                                  width: 300,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 500,
                                  width: 300,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.book,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 32),

                        // Detalles del libro
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.titulo,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (book.subtitulo != null && book.subtitulo!.isNotEmpty)
                                Text(
                                  book.subtitulo!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              const SizedBox(height: 24),

                              // Tabla con atributos
                              Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(160),
                                  1: FlexColumnWidth(),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  _buildRow('Autor', book.autor),
                                  _buildRow('Editorial', book.editorial),
                                  _buildRow('Colección', book.coleccion ?? '-'),
                                  _buildRow('Año', book.anio.toString()),
                                  _buildRow('ISBN', book.isbn ?? '-'),
                                  _buildRow('Edición', book.edicion.toString()),
                                  _buildRow('Ejemplares', book.copias.toString()),
                                  _buildRow('Precio', '\$${book.precio.toStringAsFixed(2)}'),
                                  _buildRow('Formato', book.formato),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),

                        // Botones de acción alineados verticalmente
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
                            const SizedBox(height: 12),
                            _buildActionButton(Icons.download, 'Descargar'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String label, dynamic value) {
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
          child: Text(value?.toString() ?? '-'),
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
      onPressed: () {}, // Aquí puedes agregar las acciones correspondientes
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
