import 'package:flutter/material.dart';
import '../models/bookM.dart';
import '../viewmodels/bookVM.dart';
import 'addbk.dart';

class InventarioPage extends StatefulWidget {
  final Function(Book) onBookSelected;

  const InventarioPage({required this.onBookSelected, super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final BookViewModel _viewModel = BookViewModel();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARRA DE BÚSQUEDA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 800,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
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
                child: Text('EU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.04),

          // TÍTULO Y BOTONES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Libros', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  // Botón FILTRAR
                  _buildOutlinedButton(Icons.filter_list, 'Filtrar', () {}),
                  const SizedBox(width: 12),
                  // Botón EXPORTAR
                  _buildOutlinedButton(Icons.download, 'Exportar', () {}),
                  const SizedBox(width: 12),
                  // Botón AGREGAR LIBRO
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar libro'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddBookDialog(
                          onAdd: (newBook) => _viewModel.addBook(newBook),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // TABLA DE LIBROS
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // Encabezados
                  _buildHeaderRow(),
                  const Divider(),

                  // Lista dinámica desde Firestore
                  Expanded(
                    child: StreamBuilder<List<Book>>(
                      stream: _viewModel.getBooksStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No hay libros disponibles'));
                        }

                        final query = _searchQuery.toLowerCase();
                        final books = snapshot.data!
                            .where((book) =>
                                (book.titulo).toLowerCase().contains(query) || 
                                (book.autor).toLowerCase().contains(query) ||
                                (book.subtitulo ?? '').toLowerCase().contains(query) ||
                                (book.editorial).toLowerCase().contains(query) ||
                                (book.coleccion ?? '').toLowerCase().contains(query) ||
                                (book.isbn ?? '').toLowerCase().contains(query) ||
                                (book.formato).toLowerCase().contains(query))
                            .toList();


                        return ListView.separated(
                          itemCount: books.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return BookRow(
                              imageUrl: book.imagenUrl ?? '',
                              title: book.titulo,
                              subtitle: book.subtitulo ?? '-',
                              author: book.autor,
                              editorial: book.editorial,
                              collection: book.coleccion ?? '-',
                              year: book.anio.toString(),
                              isbn: book.isbn ?? '-',
                              edition: book.edicion.toString(),
                              copies: book.copias.toString(),
                              price: '\$${book.precio.toStringAsFixed(2)}',
                              format: book.formato,
                              onTap: () => widget.onBookSelected(book),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(IconData icon, String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        borderRadius: BorderRadius.circular(12),
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[700],
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold);
    return Row(
      children: const [
        Expanded(child: Text('Portada', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Título', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Subtítulo', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Autor', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Editorial', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Colección', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Año', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('ISBN', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Edición', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Ejemplares', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Precio', style: headerStyle)),
        VerticalDivider(),
        Expanded(child: Text('Formato', style: headerStyle)),
      ],
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
          Expanded(child: Image.network(imageUrl, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported))),
          const VerticalDivider(),
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          const VerticalDivider(),
          Expanded(child: Text(subtitle, overflow: TextOverflow.ellipsis)),
          const VerticalDivider(),
          Expanded(child: Text(author, overflow: TextOverflow.ellipsis)),
          const VerticalDivider(),
          Expanded(child: Text(editorial, overflow: TextOverflow.ellipsis)),
          const VerticalDivider(),
          Expanded(child: Text(collection, overflow: TextOverflow.ellipsis)),
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
