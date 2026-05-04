import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/book_m.dart';
import '../../models/donation_m.dart';
import '../../viewmodels/donation/donation_vm.dart';
import '../../viewmodels/book/book_vm.dart'; // para buscar libros
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

// ─── Modelo interno para cada fila seleccionada ────────────────────────────
class _DonationEntry {
  final Book book;
  final TextEditingController cantidadCtrl;

  _DonationEntry({required this.book})
      : cantidadCtrl = TextEditingController(text: '1');

  void dispose() => cantidadCtrl.dispose();
}

// ─── Widget principal ──────────────────────────────────────────────────────
class DonateDialog extends StatefulWidget {
  final Function(List<Book>) onDonated;

  const DonateDialog({required this.onDonated, super.key});

  @override
  State<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  final _formKey = GlobalKey<FormState>();
  final DonationsViewModel _donationsVM = DonationsViewModel();
  final BookViewModel _bookVM = BookViewModel();

  // ─── Controllers globales ────────────────────────────────────────────────
  final _lugarController = TextEditingController();
  final _notaController  = TextEditingController();

  // ─── Búsqueda ────────────────────────────────────────────────────────────
  final _searchController    = TextEditingController();
  final _searchFocusNode     = FocusNode();
  List<Book> _searchResults  = [];
  bool _isSearching          = false;
  bool _showResults          = false;

  // ─── Lista de libros seleccionados ────────────────────────────────────────
  final List<_DonationEntry> _entries = [];

  @override
  void dispose() {
    _lugarController.dispose();
    _notaController.dispose();
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

    // Usa tu método existente en BookViewModel para buscar por título
    final results = await _bookVM.searchByTitle(query.trim());

    setState(() {
      _searchResults = results;
      _isSearching   = false;
      _showResults   = true;
    });
  }

  void _addEntry(Book book) {
    // Evitar duplicados
    final alreadyAdded = _entries.any((e) => e.book.id == book.id);
    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este libro ya está en la lista'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _entries.add(_DonationEntry(book: book));
      _searchController.clear();
      _searchResults = [];
      _showResults   = false;
    });

    _searchFocusNode.unfocus();
  }

  void _removeEntry(int index) {
    final entry = _entries[index];
    entry.dispose();
    setState(() => _entries.removeAt(index));
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────
  Future<void> _saveDonations() async {
    if (!_formKey.currentState!.validate()) return;

    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un libro a la donación'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final user    = FirebaseAuth.instance.currentUser;
    final lugar   = _lugarController.text.trim();
    final nota    = _notaController.text.trim();
    final fecha   = DateTime.now();
    final updatedBooks = <Book>[];

    try {
      for (final entry in _entries) {
        final cantidad = int.tryParse(entry.cantidadCtrl.text) ?? 1;

        final donation = Donation(
          bookId:    entry.book.id!,
          titulo:    entry.book.titulo,
          autor:     entry.book.autor,
          cantidad:  cantidad,
          fecha:     fecha,
          userId:    user?.uid   ?? 'anonimo',
          userEmail: user?.email ?? 'anonimo',
          lugar:     lugar,
          nota:      nota,
        );

        await _donationsVM.addDonation(donation);

        updatedBooks.add(
          entry.book.copyWith(copias: entry.book.copias - cantidad),
        );
      }

      widget.onDonated(updatedBooks);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar donación: $e')),
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
        title: 'Registrar donación',
        headerIcon: CupertinoIcons.gift_fill,
        onSave: _saveDonations,
        saveLabel: 'Registrar donación',
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Buscador de libros ─────────────────────────────────────────
            PanelSection(
              title: 'Libros a donar',
              children: [
                _buildSearchField(),
                if (_entries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildEntriesList(),
                ],
              ],
            ),

            // ── Datos comunes ──────────────────────────────────────────────
            PanelSection(
              title: 'Datos de la donación',
              children: [
                panelField(
                  'Lugar de la donación',
                  _lugarController,
                  hint: 'Ej. Biblioteca Municipal',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                panelLabeledField(
                  label: 'Nota',
                  required: false,
                  child: TextFormField(
                    controller: _notaController,
                    maxLines: 3,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF1C2532)),
                    decoration: panelInputDecoration(
                        hint: 'Observaciones adicionales (opcional)'),
                  ),
                ),
              ],
              showDividerAfter: false,
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
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF1C2532)),
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
                            strokeWidth: 2,
                            color: Color(0xFF052B67)),
                      ),
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // Resultados de búsqueda
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
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _searchResults.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Sin resultados',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, _) => const Divider(
                        height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (_, i) {
                      final book = _searchResults[i];
                      final alreadyAdded =
                          _entries.any((e) => e.book.id == book.id);
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
                                  child: Image.network(
                                    book.imagenUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(CupertinoIcons.book,
                                            size: 18,
                                            color: Color(0xFF052B67)),
                                  ),
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
                        subtitle: Text(
                          book.autor,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7280)),
                        ),
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

  // ─── Lista de entradas seleccionadas ──────────────────────────────────────
  Widget _buildEntriesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de columnas
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: const [
              Expanded(
                flex: 5,
                child: Text('Libro',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: Text('Copias disp.',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280)),
                    textAlign: TextAlign.center),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: Text('Cantidad',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280)),
                    textAlign: TextAlign.center),
              ),
              SizedBox(width: 36), // espacio botón eliminar
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
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFEEF0F4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.book.titulo,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C2532)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          entry.book.autor,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Copias disponibles (informativo)
                SizedBox(
                  width: 80,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${entry.book.copias}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF052B67)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Campo cantidad
                SizedBox(
                  width: 72,
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

                // Botón eliminar fila
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
}

// ─── Función de apertura ───────────────────────────────────────────────────
void showDonateDialog(
    BuildContext context, Function(List<Book>) onDonated) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Registrar donación',
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
          child: DonateDialog(onDonated: onDonated),
        ),
      );
    },
  );
}