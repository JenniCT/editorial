import 'package:flutter/material.dart';
import '../../models/book_m.dart';
import '../../widgets/global/search.dart';

class BookSearchView extends StatefulWidget {
  final List<Book> allBooks;
  const BookSearchView({required this.allBooks, super.key});

  @override
  State<BookSearchView> createState() => _BookSearchViewState();
}

class _BookSearchViewState extends State<BookSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> filteredBooks = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Search<Book>(
          controller: _searchController,
          allItems: widget.allBooks,
          onResults: (results) {
            setState(() {
              filteredBooks = results;
            });
          },
          filter: (book, query) {
            return book.tituloLower.contains(query) ||
                book.autorLower.contains(query) ||
                (book.subtitulo ?? '').toLowerCase().contains(query) ||
                book.editorialLower.contains(query) ||
                (book.coleccion ?? '').toLowerCase().contains(query) ||
                (book.isbn ?? '').toLowerCase().contains(query) ||
                book.estante.toString().contains(query) ||
                book.almacen.toString().contains(query) ||
                book.copias.toString().contains(query) ||
                book.areaLower.contains(query);
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredBooks.isEmpty ? widget.allBooks.length : filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks.isEmpty ? widget.allBooks[index] : filteredBooks[index];
              return ListTile(
                title: Text(book.titulo),
                subtitle: Text(book.autor),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
