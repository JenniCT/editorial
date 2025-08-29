import 'package:flutter/material.dart';
import '../models/book_m.dart';

class Search extends StatefulWidget {
  final TextEditingController controller;
  final List<Book> allBooks;
  final ValueChanged<List<Book>> onResults;

  const Search({
    required this.controller,
    required this.allBooks,
    required this.onResults,
    super.key,
  });

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool _loading = false;


  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = widget.controller.text.trim().toLowerCase();
    _filterBooks(query);
  }

  void _filterBooks(String query) {
    if (query.isEmpty) {
      widget.onResults([]);
      return;
    }

    setState(() => _loading = true);

    final filtered = widget.allBooks.where((book) =>
      book.tituloLower.contains(query) ||
      book.autorLower.contains(query) ||
      (book.subtitulo ?? '').toLowerCase().contains(query) ||
      book.editorialLower.contains(query) ||
      (book.coleccion ?? '').toLowerCase().contains(query) ||
      (book.isbn ?? '').toLowerCase().contains(query) ||
      book.estante.toString().contains(query) ||
      book.almacen.toString().contains(query) ||
      book.copias.toString().contains(query) ||
      book.areaLower.contains(query)
    ).toList();

    widget.onResults(filtered);

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
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
              controller: widget.controller,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              cursorColor: const Color.fromRGBO(47, 65, 87, 1),
              decoration: InputDecoration(
                hintText: 'Buscar por título, autor, editorial...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    semanticLabel: 'Buscar',
                  ),
          ),
        ],
      ),
    );
  }
}