import 'package:flutter/material.dart';

class Search<T> extends StatefulWidget {
  final TextEditingController controller;
  final List<T> allItems;
  final ValueChanged<List<T>> onResults;
  final bool Function(T item, String query) filter;

  const Search({
    required this.controller,
    required this.allItems,
    required this.onResults,
    required this.filter,
    super.key,
  });

  @override
  State<Search<T>> createState() => _SearchState<T>();
}

class _SearchState<T> extends State<Search<T>> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = widget.controller.text.trim().toLowerCase();
    _filterItems(query);
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      widget.onResults([]);
      return;
    }

    setState(() => _loading = true);

    final filtered = widget.allItems.where((item) => widget.filter(item, query)).toList();

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
        borderRadius: BorderRadius.circular(12),
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
                hintText: 'Buscar...',
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
