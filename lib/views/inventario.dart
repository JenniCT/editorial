import 'package:flutter/material.dart';
import '../models/bookdata.dart';

class InventarioPage extends StatelessWidget {
  final Function(BookData) onBookSelected;
  const InventarioPage({required this.onBookSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final book = BookData(
      imageUrl: 'https://th.bing.com/th/id/R.96daf80eb401e6eca4c96e5c6a2ab7ac?rik=HpeztcqjJWyrzw&pid=ImgRaw&r=0',
      title: 'Cien años de soledad',
      subtitle: 'Una obra maestra del realismo mágico',
      author: 'Gabriel García Márquez',
      editorial: 'Sudamericana',
      collection: 'Clásicos Latinoamericanos',
      year: '1967',
      isbn: '9784361878',
      edition: '1ª',
      copies: '5',
      price: '\$20.00',
      format: 'Impreso',
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Barra de búsqueda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar libros...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text('JC'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 📚 Título y botones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Libros',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir libro'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Exportar'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filtrar'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🧾 Tabla
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 🔠 Encabezado
                Row(
                  children: const [
                    Expanded(child: Text('Portada', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Título', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Subtítulo', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Autor', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Editorial', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Colección', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Año', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('ISBN', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Edición', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Ejemplares', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
                    VerticalDivider(),
                    Expanded(child: Text('Formato', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const Divider(),

                // 📚 Filas con onTap
                BookRow(
                  imageUrl: book.imageUrl,
                  title: book.title,
                  subtitle: book.subtitle,
                  author: book.author,
                  editorial: book.editorial,
                  collection: book.collection,
                  year: book.year,
                  isbn: book.isbn,
                  edition: book.edition,
                  copies: book.copies,
                  price: book.price,
                  format: book.format,
                  onTap: () => onBookSelected(book),
                ),
                const Divider(),
                BookRow(
                  imageUrl: book.imageUrl,
                  title: book.title,
                  subtitle: book.subtitle,
                  author: book.author,
                  editorial: book.editorial,
                  collection: book.collection,
                  year: book.year,
                  isbn: book.isbn,
                  edition: book.edition,
                  copies: book.copies,
                  price: book.price,
                  format: book.format,
                  onTap: () => onBookSelected(book),
                ),
                const Divider(),
                BookRow(
                  imageUrl: book.imageUrl,
                  title: book.title,
                  subtitle: book.subtitle,
                  author: book.author,
                  editorial: book.editorial,
                  collection: book.collection,
                  year: book.year,
                  isbn: book.isbn,
                  edition: book.edition,
                  copies: book.copies,
                  price: book.price,
                  format: book.format,
                  onTap: () => onBookSelected(book),
                ),
                const Divider(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BookRow extends StatelessWidget {
  final String imageUrl, title, subtitle, author, editorial, collection, year, isbn, edition, copies, price, format;
  final VoidCallback onTap;

  const BookRow({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.editorial,
    required this.collection,
    required this.year,
    required this.isbn,
    required this.edition,
    required this.copies,
    required this.price,
    required this.format,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: Image.network(imageUrl, height: 60, fit: BoxFit.cover)),
          const VerticalDivider(),
          Expanded(child: Text(title)),
          const VerticalDivider(),
          Expanded(child: Text(subtitle)),
          const VerticalDivider(),
          Expanded(child: Text(author)),
          const VerticalDivider(),
          Expanded(child: Text(editorial)),
          const VerticalDivider(),
          Expanded(child: Text(collection)),
          const VerticalDivider(),
          Expanded(child: Text(year)),
          const VerticalDivider(),
          Expanded(child: Text(isbn)),
          const VerticalDivider(),
          Expanded(child: Text(edition)),
          const VerticalDivider(),
          Expanded(child: Text(copies)),
          const VerticalDivider(),
          Expanded(child: Text(price)),
          const VerticalDivider(),
          Expanded(child: Text(format)),
        ],
      ),
    );
  }
}