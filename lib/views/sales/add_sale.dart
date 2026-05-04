import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/book_m.dart';
import '../../models/sale_m.dart';
import '../../viewmodels/market/sales_vm.dart';
import '../../viewmodels/book/book_vm.dart';
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

// ─── Modelo interno por fila ───────────────────────────────────────────────
class _SaleEntry {
  final Book book;
  final TextEditingController cantidadCtrl;
  final TextEditingController precioCtrl;

  _SaleEntry({required this.book})
      : cantidadCtrl = TextEditingController(text: '1'),
        precioCtrl   = TextEditingController(text: '0.00');

  double get subtotal {
    final cantidad = int.tryParse(cantidadCtrl.text) ?? 0;
    final precio   = double.tryParse(precioCtrl.text) ?? 0.0;
    return cantidad * precio;
  }

  void dispose() {
    cantidadCtrl.dispose();
    precioCtrl.dispose();
  }
}

// ─── Widget principal ──────────────────────────────────────────────────────
class SellDialog extends StatefulWidget {
  final Function(List<Book>) onSold;

  const SellDialog({required this.onSold, super.key});

  @override
  State<SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<SellDialog> {
  final _formKey   = GlobalKey<FormState>();
  final _salesVM   = SalesViewModel();
  final _bookVM    = BookViewModel();

  // ─── Controllers globales ────────────────────────────────────────────────
  final _lugarController = TextEditingController();

  // ─── Búsqueda ────────────────────────────────────────────────────────────
  final _searchController = TextEditingController();
  final _searchFocusNode  = FocusNode();
  List<Book> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  // ─── Entradas ────────────────────────────────────────────────────────────
  final List<_SaleEntry> _entries = [];

  // ─── Total general ────────────────────────────────────────────────────────
  double get _totalGeneral =>
      _entries.fold(0.0, (sum, e) => sum + e.subtotal);

  @override
  void dispose() {
    _lugarController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  // ─── Búsqueda ─────────────────────────────────────────────────────────────
  Future<void> _onSearchChanged(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _showResults   = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await _bookVM.searchByTitle(query.trim());
    setState(() {
      _searchResults = results;
      _isSearching   = false;
      _showResults   = true;
    });
  }

  void _addEntry(Book book) {
    if (_entries.any((e) => e.book.id == book.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este libro ya está en la lista'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final entry = _SaleEntry(book: book);
    // Recalcular total al escribir en cualquier campo
    entry.cantidadCtrl.addListener(() => setState(() {}));
    entry.precioCtrl.addListener(() => setState(() {}));

    setState(() {
      _entries.add(entry);
      _searchController.clear();
      _searchResults = [];
      _showResults   = false;
    });
    _searchFocusNode.unfocus();
  }

  void _removeEntry(int index) {
    _entries[index].dispose();
    setState(() => _entries.removeAt(index));
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────
  Future<void> _saveSales() async {
    if (!_formKey.currentState!.validate()) return;

    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un libro a la venta'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final user          = FirebaseAuth.instance.currentUser;
    final lugar         = _lugarController.text.trim();
    final fecha         = DateTime.now();
    final updatedBooks  = <Book>[];

    try {
      for (final entry in _entries) {
        final cantidad = int.tryParse(entry.cantidadCtrl.text) ?? 1;
        final precio   = double.tryParse(entry.precioCtrl.text) ?? 0.0;
        final total    = cantidad * precio;

        final sale = Sale(
          bookId:    entry.book.id!,
          titulo:    entry.book.titulo,
          autor:     entry.book.autor,
          cantidad:  cantidad,
          fecha:     fecha,
          userId:    user?.uid   ?? 'anonimo',
          userEmail: user?.email ?? 'anonimo',
          lugar:     lugar,
          total:     total,
          precioUnitario: precio, 
        );

        await _salesVM.addSale(sale);

        updatedBooks.add(
          entry.book.copyWith(copias: entry.book.copias - cantidad),
        );
      }

      widget.onSold(updatedBooks);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar venta: $e')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title: 'Registrar venta',
        headerIcon: CupertinoIcons.cart_fill,
        onSave: _saveSales,
        saveLabel: 'Registrar venta',
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Buscador ──────────────────────────────────────────────────
            PanelSection(
              title: 'Libros a vender',
              children: [
                _buildSearchField(),
                if (_entries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildEntriesList(),
                  const SizedBox(height: 12),
                  _buildTotalBar(),
                ],
              ],
            ),

            // ── Datos comunes ─────────────────────────────────────────────
            PanelSection(
              title: 'Datos de la venta',
              showDividerAfter: false,
              children: [
                panelField(
                  'Lugar de la venta',
                  _lugarController,
                  hint: 'Ej. Feria del libro UNAM',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Buscador ─────────────────────────────────────────────────────────────
  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        panelLabeledField(
          label: 'Buscar libro por título',
          child: TextFormField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1C2532)),
            decoration: panelInputDecoration(hint: 'Escribe para buscar...')
                .copyWith(
              prefixIcon: const Icon(CupertinoIcons.search,
                  size: 16, color: Color(0xFF6B7280)),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF052B67)),
                      ),
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        if (_showResults) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEEF0F4)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4)),
              ],
            ),
            child: _searchResults.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sin resultados',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF6B7280))),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (_, i) {
                      final book        = _searchResults[i];
                      final alreadyAdded = _entries.any((e) => e.book.id == book.id);
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5FB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: book.imagenUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(book.imagenUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                          CupertinoIcons.book,
                                          size: 18,
                                          color: Color(0xFF052B67))),
                                )
                              : const Icon(CupertinoIcons.book,
                                  size: 18, color: Color(0xFF052B67)),
                        ),
                        title: Text(
                          book.titulo,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: alreadyAdded
                                ? const Color(0xFFAAAAAA)
                                : const Color(0xFF1C2532),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(book.autor,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280))),
                        trailing: alreadyAdded
                            ? const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF052B67), size: 18)
                            : const Icon(Icons.add_circle_outline_rounded,
                                color: Color(0xFF052B67), size: 18),
                        onTap: alreadyAdded ? null : () => _addEntry(book),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }

  // ─── Lista de entradas ────────────────────────────────────────────────────
  Widget _buildEntriesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado columnas
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: const [
              Expanded(
                flex: 4,
                child: Text('Libro',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: Text('Disp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: Text('Cant.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: Text('Precio u.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: Text('Subtotal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
              SizedBox(width: 36),
            ],
          ),
        ),

        // Filas
        ...List.generate(_entries.length, (i) {
          final entry = _entries[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título + autor
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEEF0F4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.book.titulo,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C2532)),
                            overflow: TextOverflow.ellipsis),
                        Text(entry.book.autor,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280)),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Copias disponibles
                SizedBox(
                  width: 64,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${entry.book.copias}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF052B67))),
                  ),
                ),
                const SizedBox(width: 8),

                // Cantidad
                SizedBox(
                  width: 64,
                  child: TextFormField(
                    controller: entry.cantidadCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C2532)),
                    decoration: panelInputDecoration(),
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Inválido';
                      if (val > entry.book.copias) return 'Excede';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Precio unitario
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: entry.precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C2532)),
                    decoration: panelInputDecoration(hint: '0.00').copyWith(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 8, right: 2),
                        child: Text('\$',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280))),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val < 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Subtotal (calculado, solo lectura)
                SizedBox(
                  width: 72,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF7EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${entry.subtotal.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Eliminar fila
                SizedBox(
                  width: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: Colors.redAccent, size: 20),
                    onPressed: () => _removeEntry(i),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Barra de total general ───────────────────────────────────────────────
  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF052B67),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total de la venta',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70),
          ),
          Text(
            '\$${_totalGeneral.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Función de apertura ───────────────────────────────────────────────────
void showSellDialog(BuildContext context, Function(List<Book>) onSold) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Registrar venta',
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: Align(
          alignment: Alignment.centerRight,
          child: SellDialog(onSold: onSold),
        ),
      );
    },
  );
}