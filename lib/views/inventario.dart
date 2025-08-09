import 'package:flutter/material.dart';
import '../models/bookdata.dart';
import 'addbk.dart';

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
          // BARRA DE BÚSQUEDA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 800,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Buscar libros...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(Icons.search, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  'EU',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
            ],
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.04),

          // TITULO Y BOTONES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Libros',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // FILTRAR
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filtrar'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),

                  // EXPORTAR
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Exportar'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),

                  // AGREGAR LIBRO
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar libro'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddBookDialog(
                            onAdd: (newBook) {
                              print('Libro agregado: ${newBook.title}');
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // TABLA
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
                // ENCABEZADO
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

                // FILAS
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