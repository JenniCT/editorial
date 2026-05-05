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
import '../../widgets/global/info_banner.dart';

import '../../widgets/global/dialog.dart';

// ─── Origen ───────────────────────────────────────────────────────────────
enum SaleOrigin { estante, almacen }

// ─── Modelo interno por fila ───────────────────────────────────────────────
class _SaleEntry {
  final Book book;
  final TextEditingController cantidadCtrl;
  final TextEditingController precioCtrl;

  SaleOrigin? origin;
  bool stockInsuficienteTotal  = false;
  bool stockInsuficienteOrigen = false;
  bool usarComplemento         = false;
  bool isExpanded              = true;

  _SaleEntry({required this.book})
      : cantidadCtrl = TextEditingController(text: '1'),
        precioCtrl   = TextEditingController(text: '0.00');

  int    get cantidad      => int.tryParse(cantidadCtrl.text)  ?? 0;
  double get precio        => double.tryParse(precioCtrl.text) ?? 0.0;
  int    get copiasTotales => book.copias;
  int    get copiasEstante => book.estante;
  int    get copiasAlmacen => book.almacen;
  double get subtotal      => cantidad * precio;
  bool   get consumeTodo   => cantidad == copiasTotales && cantidad > 0;

  ({int deEstante, int deAlmacen}) get descuento {
    if (consumeTodo) return (deEstante: copiasEstante, deAlmacen: copiasAlmacen);
    if (origin == SaleOrigin.estante) {
      if (usarComplemento && cantidad > copiasEstante) {
        return (deEstante: copiasEstante, deAlmacen: cantidad - copiasEstante);
      }
      return (deEstante: cantidad, deAlmacen: 0);
    } else {
      if (usarComplemento && cantidad > copiasAlmacen) {
        return (deAlmacen: copiasAlmacen, deEstante: cantidad - copiasAlmacen);
      }
      return (deAlmacen: cantidad, deEstante: 0);
    }
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
  final _formKey          = GlobalKey<FormState>();
  final _salesVM          = SalesViewModel();
  final _bookVM           = BookViewModel();
  final _lugarController  = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocusNode  = FocusNode();

  List<Book>             _searchResults = [];
  bool                   _isSearching   = false;
  bool                   _showResults   = false;
  final List<_SaleEntry> _entries       = [];

  double get _totalGeneral => _entries.fold(0.0, (s, e) => s + e.subtotal);

  @override
  void dispose() {
    _lugarController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    for (final e in _entries) {e.dispose();}
    super.dispose();
  }

  // ─── Búsqueda ─────────────────────────────────────────────────────────────
  Future<void> _onSearchChanged(String query) async {
    if (query.trim().length < 2) {
      setState(() { _searchResults = []; _showResults = false; });
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
      showCustomToast(context, title: 'Libro duplicado', message: 'Este libro ya está en la lista', color: Colors.orange, icon: CupertinoIcons.exclamationmark_circle_fill);
      return;
    }

    final entry = _SaleEntry(book: book);
    entry.cantidadCtrl.addListener(() => _onCantidadChanged(entry));
    entry.precioCtrl.addListener(() => setState(() {}));

    setState(() {
      // Colapsa el último antes de agregar el nuevo
      if (_entries.isNotEmpty) {
        _entries.last.isExpanded = false;
      }
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

  // ─── Lógica: cantidad ─────────────────────────────────────────────────────
  void _onCantidadChanged(_SaleEntry entry) {
    setState(() {
      entry.stockInsuficienteTotal  = false;
      entry.stockInsuficienteOrigen = false;
      entry.usarComplemento         = false;
      entry.origin                  = null;
      final cant = entry.cantidad;
      if (cant <= 0) return;
      if (cant > entry.copiasTotales) entry.stockInsuficienteTotal = true;
    });
  }

  // ─── Lógica: origen ───────────────────────────────────────────────────────
  Future<void> _onOriginChanged(_SaleEntry entry, SaleOrigin newOrigin) async {
    setState(() {
      entry.origin                  = newOrigin;
      entry.stockInsuficienteOrigen = false;
      entry.usarComplemento         = false;
    });

    final cant         = entry.cantidad;
    final esEstante    = newOrigin == SaleOrigin.estante;
    final disponible   = esEstante ? entry.copiasEstante : entry.copiasAlmacen;
    final disponOtro   = esEstante ? entry.copiasAlmacen : entry.copiasEstante;
    final origenLabel  = esEstante ? 'estante' : 'almacén';
    final otroLabel    = esEstante ? 'almacén' : 'estante';

    if (cant > disponible) {
      final faltante = cant - disponible;
      if (faltante <= disponOtro) {
        final aceptar = await _mostrarDialogoComplemento(
          titulo:      entry.book.titulo,
          cant:        cant,
          disponible:  disponible,
          faltante:    faltante,
          origenLabel: origenLabel,
          otroLabel:   otroLabel,
        );
        setState(() {
          if (aceptar == true) {
            entry.usarComplemento = true;
          } else {
            entry.origin                  = null;
            entry.stockInsuficienteOrigen = aceptar == false;
          }
        });
      } else {
        setState(() {
          entry.stockInsuficienteOrigen = true;
          entry.origin                  = null;
        });
        showCustomToast(context, title: 'Stock insuficiente', message: 'No hay suficientes copias en $origenLabel ni completando con $otroLabel.', color: Colors.redAccent, icon: CupertinoIcons.xmark_circle_fill);
      }
    }
  }

  // ─── Diálogo complemento ──────────────────────────────────────────────────
  Future<bool?> _mostrarDialogoComplemento({
    required String titulo,
    required int    cant,
    required int    disponible,
    required int    faltante,
    required String origenLabel,
    required String otroLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding:   const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(CupertinoIcons.exclamationmark_triangle_fill,
                  size: 16, color: Color(0xFFDC2626)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Stock insuficiente en origen',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 16),
            InfoBanner(
              type:    BannerType.error,
              message: 'En $origenLabel solo hay $disponible copia(s) de "$titulo", '
                       'pero deseas vender $cant.',
            ),
            const SizedBox(height: 10),
            InfoBanner(
              type:    BannerType.warning,
              message: '¿Deseas tomar los $faltante ejemplar(es) faltante(s) desde $otroLabel?',
            ),
            const SizedBox(height: 4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'No, cambiar origen o cantidad',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF052B67),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, completar',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────
  Future<void> _saveSales() async {
    if (!_formKey.currentState!.validate()) throw Exception('_validation');

    if (_entries.isEmpty) {
      showCustomToast(context, title: 'Sin libros', message: 'Agrega al menos un libro a la venta', color: Colors.redAccent, icon: CupertinoIcons.xmark_circle_fill);
      throw Exception('_empty');
    }

    for (final entry in _entries) {
      if (entry.stockInsuficienteTotal) {
        showCustomToast(context, title: 'Stock insuficiente', message: '"${entry.book.titulo}" supera el stock disponible.', color: Colors.redAccent, icon: CupertinoIcons.xmark_circle_fill);
        throw Exception('_stock');
      }
      if (!entry.consumeTodo && entry.origin == null) {
        showCustomToast(context, title: 'Origen requerido', message: 'Selecciona el origen de venta para "${entry.book.titulo}".', color: Colors.orange, icon: CupertinoIcons.exclamationmark_circle_fill);
        throw Exception('_origin');
      }
    }

    final user         = FirebaseAuth.instance.currentUser;
    final lugar        = _lugarController.text.trim();
    final fecha        = DateTime.now();
    final updatedBooks = <Book>[];

    for (final entry in _entries) {
      final d    = entry.descuento;
      final sale = Sale(
        bookId:         entry.book.id!,
        titulo:         entry.book.titulo,
        autor:          entry.book.autor,
        cantidad:       entry.cantidad,
        fecha:          fecha,
        userId:         user?.uid   ?? 'anonimo',
        userEmail:      user?.email ?? 'anonimo',
        lugar:          lugar,
        total:          entry.subtotal,
        precioUnitario: entry.precio,
        deEstante:      d.deEstante,
        deAlmacen:      d.deAlmacen,
      );
      try {
        await _salesVM.addSaleWithOrigin(sale, d.deEstante, d.deAlmacen, context); // ← context
      } catch (e) {
        if (mounted) {
          showCustomToast(context, title: 'Error', message: 'No se pudo registrar "${entry.book.titulo}".', color: Colors.redAccent, icon: CupertinoIcons.xmark_circle_fill, durationSeconds: 3);
        }
        rethrow;
      }
      updatedBooks.add(entry.book.copyWith(
        copias:  entry.book.copias   - entry.cantidad,
        estante: entry.copiasEstante - d.deEstante,
        almacen: entry.copiasAlmacen - d.deAlmacen,
      ));
    }

    widget.onSold(updatedBooks);
  }

  // ─── Build principal ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title:      'Registrar venta',
        headerIcon: CupertinoIcons.cart_fill,
        onSave:     _saveSales,
        saveLabel:  'Registrar venta',
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            PanelSection(
              title:            'Datos de la venta',
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
            focusNode:  _searchFocusNode,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1C2532)),
            decoration: panelInputDecoration(hint: 'Escribe para buscar...')
                .copyWith(
              prefixIcon: const Icon(CupertinoIcons.search,
                  size: 16, color: Color(0xFF6B7280)),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16, height: 16,
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
              color:        Colors.white,
              borderRadius: BorderRadius.circular(8),
              border:       Border.all(color: const Color(0xFFEEF0F4)),
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
                      final book         = _searchResults[i];
                      final alreadyAdded = _entries.any((e) => e.book.id == book.id);
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color:        const Color(0xFFF1F5FB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: book.imagenUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(book.imagenUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const Icon(CupertinoIcons.book,
                                              size: 18,
                                              color: Color(0xFF052B67))),
                                )
                              : const Icon(CupertinoIcons.book,
                                  size: 18, color: Color(0xFF052B67)),
                        ),
                        title: Text(book.titulo,
                            style: TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                              color: alreadyAdded
                                  ? const Color(0xFFAAAAAA)
                                  : const Color(0xFF1C2532),
                            ),
                            overflow: TextOverflow.ellipsis),
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
      children: List.generate(_entries.length, (i) => _buildEntryRow(_entries[i], i)),
    );
  }

  // ─── Card por libro ───────────────────────────────────────────────────────
  Widget _buildEntryRow(_SaleEntry entry, int i) {
    final bloqueado   = entry.stockInsuficienteTotal;
    final complemento = entry.usarComplemento;
    final expanded    = entry.isExpanded;

    // Resumen compacto de estado para la vista colapsada
    String resumenColapsado() {
      if (bloqueado) return 'Stock insuficiente';
      if (entry.cantidad <= 0) return 'Sin cantidad';
      if (entry.consumeTodo) return '${entry.cantidad} uds · Auto · \$${entry.subtotal.toStringAsFixed(2)}';
      if (entry.origin == null) return '${entry.cantidad} uds · Sin origen · \$${entry.subtotal.toStringAsFixed(2)}';
      final origenLabel = entry.origin == SaleOrigin.estante ? 'Estante' : 'Almacén';
      return '${entry.cantidad} uds · $origenLabel · \$${entry.subtotal.toStringAsFixed(2)}';
    }

    Color borderColor() {
      if (bloqueado) return const Color.fromRGBO(255, 82, 82, 0.35);
      if (!expanded && entry.origin == null && entry.cantidad > 0 && !entry.consumeTodo) {
        return const Color.fromRGBO(255, 152, 0, 0.4);
      }
      return const Color(0xFFEEF0F4);
    }

    Color bgColor() {
      if (bloqueado) return const Color(0xFFFFF3F3);
      return const Color(0xFFF8FAFC);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor(),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Fila 1: título + toggle + eliminar ─────────────────────────
          InkWell(
            onTap: () => setState(() => entry.isExpanded = !entry.isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  // Ícono de estado colapsado
                  AnimatedRotation(
                    turns:    expanded ? 0.0 : -0.25,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(width: 8),

                  // Título + autor / resumen colapsado
                  Expanded(
                    child: expanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.book.titulo,
                                  style: const TextStyle(
                                      fontSize:   13,
                                      fontWeight: FontWeight.w600,
                                      color:      Color(0xFF1C2532)),
                                  overflow: TextOverflow.ellipsis),
                              Text(entry.book.autor,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF6B7280)),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.book.titulo,
                                  style: const TextStyle(
                                      fontSize:   13,
                                      fontWeight: FontWeight.w600,
                                      color:      Color(0xFF1C2532)),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(
                                resumenColapsado(),
                                style: TextStyle(
                                  fontSize:   11,
                                  fontWeight: FontWeight.w500,
                                  color: bloqueado
                                      ? Colors.redAccent
                                      : (!entry.consumeTodo && entry.origin == null && entry.cantidad > 0)
                                          ? Colors.orange.shade700
                                          : const Color(0xFF2E7D32),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ),

                  // Eliminar
                  IconButton(
                    padding:     EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: Colors.redAccent, size: 20),
                    onPressed: () => _removeEntry(i),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido expandible ───────────────────────────────────────
          AnimatedCrossFade(
            duration:      const Duration(milliseconds: 220),
            firstCurve:    Curves.easeInOut,
            secondCurve:   Curves.easeInOut,
            sizeCurve:     Curves.easeInOut,
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: Color(0xFFEEF0F4)),

                // Encabezados stock
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                  child: Row(children: const [
                    SizedBox(width: 110,
                        child: Text('Total', style: _labelStyle)),
                    SizedBox(width: 10),
                    SizedBox(width: 70,
                        child: Text('Estante',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0)))),
                    SizedBox(width: 6),
                    SizedBox(width: 70,
                        child: Text('Almacén',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32)))),
                  ]),
                ),

                // Valores stock
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                  child: Row(children: [
                    Container(
                      width: 110,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF3FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${entry.copiasTotales} copias',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: Color(0xFF052B67))),
                    ),
                    const SizedBox(width: 10),
                    _stockValueBox(entry.copiasEstante,
                        const Color(0xFFEFF6FF), const Color(0xFFBFDBFE), const Color(0xFF1565C0)),
                    const SizedBox(width: 6),
                    _stockValueBox(entry.copiasAlmacen,
                        const Color(0xFFF0FFF4), const Color(0xFFBBF7D0), const Color(0xFF2E7D32)),
                  ]),
                ),

                const Divider(height: 1, color: Color(0xFFEEF0F4)),

                // Encabezados controles
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                  child: Row(children: const [
                    SizedBox(width: 58,
                        child: Text('Cantidad',
                            textAlign: TextAlign.center, style: _labelStyle)),
                    SizedBox(width: 10),
                    Expanded(child: Text('Origen',
                        textAlign: TextAlign.center, style: _labelStyle)),
                    SizedBox(width: 10),
                    SizedBox(width: 88,
                        child: Text('Precio unit.',
                            textAlign: TextAlign.center, style: _labelStyle)),
                    SizedBox(width: 10),
                    Text('Subtotal', style: _labelStyle),
                  ]),
                ),

                // Controles
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                  child: Row(children: [
                    SizedBox(width: 58, child: _cantidadField(entry)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildOrigenWidget(entry)),
                    const SizedBox(width: 10),
                    SizedBox(width: 88, child: _precioField(entry)),
                    const SizedBox(width: 10),
                    _subtotalChip(entry),
                  ]),
                ),

                // Banner complemento / advertencia
                if (complemento || entry.stockInsuficienteOrigen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: complemento
                        ? InfoBanner(
                            type:    BannerType.info,
                            message: _complementoLabel(entry),
                          )
                        : InfoBanner(
                            type:    BannerType.warning,
                            message: 'Elige un origen distinto o reduce la cantidad.',
                          ),
                  ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  // ─── Constante de estilo de encabezado ────────────────────────────────────
  static const _labelStyle = TextStyle(
    fontSize:   10,
    fontWeight: FontWeight.w600,
    color:      Color(0xFF6B7280),
  );

  // ─── Caja de valor de stock ───────────────────────────────────────────────
  Widget _stockValueBox(int value, Color bg, Color border, Color text) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: border),
      ),
      child: Text('$value',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w700,
              color:      text)),
    );
  }

  // ─── Helpers de fila ──────────────────────────────────────────────────────
  String _complementoLabel(_SaleEntry e) {
    final d = e.descuento;
    return e.origin == SaleOrigin.estante
        ? '${d.deEstante} de estante + ${d.deAlmacen} de almacén'
        : '${d.deAlmacen} de almacén + ${d.deEstante} de estante';
  }

  Widget _cantidadField(_SaleEntry entry) {
    final bloqueado = entry.stockInsuficienteTotal;
    return TextFormField(
      controller:       entry.cantidadCtrl,
      keyboardType:     TextInputType.number,
      textAlign:        TextAlign.center,
      inputFormatters:  [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w600,
          color: bloqueado ? Colors.redAccent : const Color(0xFF1C2532)),
      decoration: panelInputDecoration().copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: bloqueado
                  ? Colors.redAccent
                  : const Color(0xFFE0E4EC)),
        ),
      ),
      validator: (v) {
        final val = int.tryParse(v ?? '');
        if (val == null || val <= 0)        return '!';
        if (val > entry.copiasTotales)      return '!';
        return null;
      },
    );
  }

  Widget _precioField(_SaleEntry entry) {
    return TextFormField(
      controller:   entry.precioCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign:    TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: const TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w600,
          color:      Color(0xFF1C2532)),
      decoration: panelInputDecoration(hint: '0.00').copyWith(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 8, right: 2),
          child: Text('\$',
              style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      Color(0xFF6B7280))),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: (v) {
        final val = double.tryParse(v ?? '');
        if (val == null || val < 0) return '!';
        return null;
      },
    );
  }

  Widget _subtotalChip(_SaleEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:        const Color(0xFFEEF7EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$${entry.subtotal.toStringAsFixed(2)}',
        style: const TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w700,
            color:      Color(0xFF2E7D32)),
      ),
    );
  }

  Widget _buildOrigenWidget(_SaleEntry entry) {
    if (entry.consumeTodo)            return _autoChip();
    if (entry.stockInsuficienteTotal) return _errorChip('Sin stock');
    if (entry.cantidad <= 0)          return _placeholderChip();
    return _buildOriginSelector(entry);
  }

  Widget _buildOriginSelector(_SaleEntry entry) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: entry.stockInsuficienteOrigen
              ? Colors.orange.shade400
              : const Color(0xFFE0E4EC),
        ),
      ),
      child: Row(children: [
        _originBtn('Estante', entry.origin == SaleOrigin.estante,
            () => _onOriginChanged(entry, SaleOrigin.estante), first: true),
        Container(width: 1, height: 36, color: const Color(0xFFE0E4EC)),
        _originBtn('Almacén', entry.origin == SaleOrigin.almacen,
            () => _onOriginChanged(entry, SaleOrigin.almacen), first: false),
      ]),
    );
  }

  Widget _originBtn(String label, bool selected, VoidCallback onTap,
      {required bool first}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF052B67) : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left:  first  ? const Radius.circular(7) : Radius.zero,
              right: !first ? const Radius.circular(7) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize:   11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF6B7280))),
        ),
      ),
    );
  }

  Widget _autoChip() => _chip(
      'Auto (todo)', const Color(0xFFF0FFF4),
      const Color(0xFF2E7D32), const Color(0xFFBBF7D0));

  Widget _errorChip(String msg) => _chip(
      msg, const Color(0xFFFFF3F3),
      const Color(0xFFDC2626), const Color(0xFFFECACA));

  Widget _placeholderChip() => _chip(
      '—', const Color(0xFFF8FAFC),
      const Color(0xFFCCCCCC), const Color(0xFFE0E4EC));

  Widget _chip(String label, Color bg, Color text, Color border) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w600,
              color:      text)),
    );
  }

  // ─── Total general ────────────────────────────────────────────────────────
  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        const Color(0xFF052B67),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total de la venta',
              style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      Colors.white70)),
          Text('\$${_totalGeneral.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize:   16,
                  fontWeight: FontWeight.w800,
                  color:      Colors.white)),
        ],
      ),
    );
  }
}

// ─── Apertura del panel ────────────────────────────────────────────────────
void showSellDialog(BuildContext context, Function(List<Book>) onSold) {
  showGeneralDialog(
    context:           context,
    barrierDismissible: true,
    barrierLabel:      'Registrar venta',
    barrierColor:      const Color.fromRGBO(0, 0, 0, 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder:       (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end:   Offset.zero,
        ).animate(curved),
        child: Align(
          alignment: Alignment.centerRight,
          child: SellDialog(onSold: onSold),
        ),
      );
    },
  );
}