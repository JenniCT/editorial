import 'package:flutter/material.dart';

class Search<T> extends StatefulWidget {
  final TextEditingController controller;
  final List<T> allItems;
  final ValueChanged<List<T>> onResults;
  final bool Function(T item, String query) filter;

  /// NUEVO:
  /// Placeholder reutilizable según el módulo
  final String hintText;

  const Search({
    super.key,
    required this.controller,
    required this.allItems,
    required this.onResults,
    required this.filter,
    required this.hintText,
  });

  @override
  State<Search<T>> createState() => _SearchState<T>();
}

class _SearchState<T> extends State<Search<T>> {
  bool _loading = false;
  bool _hasFocus = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onSearchChanged);

    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _hasFocus = _focusNode.hasFocus;
        });
      }
    });
  }

  void _onSearchChanged() {
    final query = widget.controller.text.trim().toLowerCase();

    // importante:
    // esto permite mostrar/ocultar el botón X
    if (mounted) {
      setState(() {});
    }

    _filterItems(query);
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      widget.onResults([]);
      return;
    }

    setState(() => _loading = true);

    final filtered = widget.allItems
        .where((item) => widget.filter(item, query))
        .toList();

    widget.onResults(filtered);

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onResults([]);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: _hasFocus
              ? const Color(0xFF1565C0)
              : const Color(0xFFE0E0E0),
          width: _hasFocus ? 1.5 : 1,
        ),

        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          const SizedBox(width: 16),

          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: const Color(0xFF1565C0),

              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C2532),
              ),

              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// BOTÓN LIMPIAR (X)
                if (hasText)
                  IconButton(
                    onPressed: _clearSearch,
                    tooltip: 'Limpiar búsqueda',
                    splashRadius: 18,
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),

                /// LOADING O ÍCONO SEARCH
                _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.search,
                        size: 22,
                        color: _hasFocus
                            ? const Color(0xFF1565C0)
                            : Colors.grey[600],
                        semanticLabel: 'Buscar',
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}