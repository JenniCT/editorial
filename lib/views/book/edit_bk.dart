import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/book_m.dart';
import '../../viewmodels/book/book_vm.dart';
import '../../widgets/side_panel/dashed_border_painter.dart';
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

class EditBookDialog extends StatefulWidget {
  final Book book;
  final void Function(Book) onUpdate;

  const EditBookDialog({required this.book, required this.onUpdate, super.key});

  @override
  State<EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<EditBookDialog> {
  final _formKey   = GlobalKey<FormState>();
  final _viewModel = BookViewModel();

  // ─── Imagen ───────────────────────────────────────────────────────────────
  File?      _selectedImage;
  Uint8List? _imageBytes;
  bool       _showUrlField = false;
  bool       _clearUrl     = false; // indica que se quitó la URL existente

  // ─── Controllers ─────────────────────────────────────────────────────────
  late final TextEditingController _imageUrlController;
  late final TextEditingController _tituloController;
  late final TextEditingController _subtituloController;
  late final TextEditingController _autorController;
  late final TextEditingController _editorialController;
  late final TextEditingController _coleccionController;
  late final TextEditingController _anioController;
  late final TextEditingController _isbnController;
  late final TextEditingController _edicionController;
  late final TextEditingController _copiasController;
  late final TextEditingController _estanteController;
  late final TextEditingController _almacenController;

  late String _selectedAreaConocimiento;
  bool _isUpdating = false;

  final List<String> _areasConocimiento = [
    'Sin definir',
    'Físico-Matemáticas y Ciencias de la Tierra',
    'Biología y Química',
    'Medicina y Ciencias de la Salud',
    'Humanidades y Ciencias de la Conducta',
    'Ciencias Sociales',
    'Biotecnología y Ciencias Agropecuarias',
    'Ingenierías',
    'Artes',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _imageUrlController   = TextEditingController(text: b.imagenUrl ?? '');
    _tituloController     = TextEditingController(text: b.titulo);
    _subtituloController  = TextEditingController(text: b.subtitulo ?? '');
    _autorController      = TextEditingController(text: b.autor);
    _editorialController  = TextEditingController(text: b.editorial);
    _coleccionController  = TextEditingController(text: b.coleccion ?? '');
    _anioController       = TextEditingController(text: b.anio.toString());
    _isbnController       = TextEditingController(text: b.isbn ?? '');
    _edicionController    = TextEditingController(text: b.edicion.toString());
    _copiasController     = TextEditingController(text: b.copias.toString());
    _estanteController    = TextEditingController(text: b.estante.toString());
    _almacenController    = TextEditingController(text: b.almacen.toString());
    _selectedAreaConocimiento = b.areaConocimiento;

    _copiasController.addListener(_onCopiasChanged);
    _estanteController.addListener(_onEstanteChanged);
    _almacenController.addListener(_onAlmacenChanged);
  }

  @override
  void dispose() {
    _copiasController.removeListener(_onCopiasChanged);
    _estanteController.removeListener(_onEstanteChanged);
    _almacenController.removeListener(_onAlmacenChanged);
    _imageUrlController.dispose();
    _tituloController.dispose();
    _subtituloController.dispose();
    _autorController.dispose();
    _editorialController.dispose();
    _coleccionController.dispose();
    _anioController.dispose();
    _isbnController.dispose();
    _edicionController.dispose();
    _copiasController.dispose();
    _estanteController.dispose();
    _almacenController.dispose();
    super.dispose();
  }

  // ─── Imagen ───────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = File(picked.path);
        _imageBytes    = bytes;
        _imageUrlController.clear();
        _clearUrl      = false;
        _showUrlField  = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes    = null;
      _imageUrlController.clear();
      _clearUrl     = true;
      _showUrlField = false;
    });
  }

  // ─── Validaciones stock ───────────────────────────────────────────────────
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2)));
  }

  void _onCopiasChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    final copias  = int.tryParse(_copiasController.text) ?? 0;
    final almacen = int.tryParse(_almacenController.text) ?? 0;
    if (almacen > copias) {
      _showError('Almacén no puede ser mayor que copias');
      _almacenController.text = copias.toString();
      _estanteController.text = '0';
    } else {
      _estanteController.text = (copias - almacen).toString();
    }
    _isUpdating = false;
  }

  void _onEstanteChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    final copias  = int.tryParse(_copiasController.text) ?? 0;
    final estante = int.tryParse(_estanteController.text) ?? 0;
    if (estante > copias) {
      _showError('Estante no puede ser mayor que copias');
      _estanteController.text = copias.toString();
      _almacenController.text = '0';
    } else {
      _almacenController.text = (copias - estante).toString();
    }
    _isUpdating = false;
  }

  void _onAlmacenChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    final copias  = int.tryParse(_copiasController.text) ?? 0;
    final almacen = int.tryParse(_almacenController.text) ?? 0;
    if (almacen > copias) {
      _showError('Almacén no puede ser mayor que copias');
      _almacenController.text = copias.toString();
      _estanteController.text = '0';
    } else {
      _estanteController.text = (copias - almacen).toString();
    }
    _isUpdating = false;
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────
  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    final updatedBook = widget.book.copyWith(
      imagenFile:   _selectedImage,
      imagenUrl:    _clearUrl
          ? null
          : (_selectedImage == null
              ? (_imageUrlController.text.trim().isNotEmpty
                  ? _imageUrlController.text.trim()
                  : widget.book.imagenUrl)
              : null),
      titulo:       _tituloController.text.trim(),
      subtitulo:    _subtituloController.text.trim().isNotEmpty
          ? _subtituloController.text.trim()
          : null,
      autor:        _autorController.text.trim(),
      editorial:    _editorialController.text.trim(),
      coleccion:    _coleccionController.text.trim().isNotEmpty
          ? _coleccionController.text.trim()
          : null,
      anio:         int.tryParse(_anioController.text) ?? widget.book.anio,
      isbn:         _isbnController.text.trim().isNotEmpty
          ? _isbnController.text.trim()
          : null,
      edicion:      int.tryParse(_edicionController.text) ?? widget.book.edicion,
      copias:       int.tryParse(_copiasController.text) ?? widget.book.copias,
      estante:      int.tryParse(_estanteController.text) ?? widget.book.estante,
      almacen:      int.tryParse(_almacenController.text) ?? widget.book.almacen,
      areaConocimiento: _selectedAreaConocimiento,
      fechaModificacion: DateTime.now(),
      modificadoPor: user?.email ?? 'desconocido',
    );

    await _viewModel.editBook(updatedBook, context);
    widget.onUpdate(updatedBook);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title:      'Editar libro',
        headerIcon: CupertinoIcons.pencil,
        onSave:     _saveBook,
        saveLabel:  'Guardar cambios',
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelSection(
              title: 'Imagen del libro',
              children: [_buildImageSection()],
            ),
            PanelSection(
              title: 'Identificación',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: panelField('Título', _tituloController,
                          hint: 'Título del libro'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: panelField('Subtítulo', _subtituloController,
                          hint: 'Opcional', required: false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                panelField('Autor(es)', _autorController,
                    hint: 'Nombre del autor'),
                const SizedBox(height: 12),
                panelField('ISBN', _isbnController,
                    hint: 'Ej. 978-607-561-088-7', required: false),
              ],
            ),
            PanelSection(
              title: 'Publicación',
              children: [
                panelField('Editorial', _editorialController,
                    hint: 'Ej. Dirección Editorial'),
                const SizedBox(height: 12),
                panelField('Colección', _coleccionController,
                    hint: 'Nombre de la colección', required: false),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: panelField('Año', _anioController,
                          hint: 'Ej. 2023',
                          onlyDigits: true,
                          maxLength: 4,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Obligatorio';
                            final yr = int.tryParse(v);
                            if (yr == null || yr < 1000 ||
                                yr > DateTime.now().year + 1) return 'Año inválido';
                            return null;
                          }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: panelField('Edición', _edicionController,
                          hint: 'Ej. 1', required: false, onlyDigits: true),
                    ),
                  ],
                ),
              ],
            ),
            PanelSection(
              title: 'Stock',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: panelField('Número de copias', _copiasController,
                          hint: '0', onlyDigits: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: panelField('Estante', _estanteController,
                          hint: '0', onlyDigits: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: panelField('Almacén', _almacenController,
                          hint: '0', onlyDigits: true),
                    ),
                  ],
                ),
              ],
            ),
            PanelSection(
              title: 'Clasificación',
              showDividerAfter: false,
              children: [
                panelLabeledField(
                  label: 'Área de conocimiento',
                  child: DropdownButtonFormField<String>(
                    value: _selectedAreaConocimiento,
                    decoration: panelInputDecoration(hint: 'Seleccione el área'),
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1C2532),
                        fontWeight: FontWeight.w500),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(10),
                    items: _areasConocimiento
                        .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(a, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedAreaConocimiento = v ?? ''),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Selecciona un área' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sección imagen ───────────────────────────────────────────────────────
  Widget _buildImageSection() {
    final hasFile = _imageBytes != null;
    final urlText = _imageUrlController.text.trim();
    final hasUrl  = !_clearUrl &&
        (hasFile == false) &&
        (urlText.isNotEmpty && urlText.startsWith('http') ||
            (widget.book.imagenUrl ?? '').startsWith('http'));

    final displayUrl = urlText.isNotEmpty ? urlText : (widget.book.imagenUrl ?? '');

    if (hasFile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(_imageBytes!,
                height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(CupertinoIcons.photo, size: 14),
                label: const Text('Cambiar'),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF052B67),
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Quitar'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      );
    }

    if (hasUrl && displayUrl.startsWith('http')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              displayUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(CupertinoIcons.photo, size: 14),
                label: const Text('Cambiar'),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF052B67),
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Quitar'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: const Color(0xFF052B67).withValues(alpha: 0.25),
            ),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.cloud_upload,
                      size: 30,
                      color: const Color(0xFF052B67).withValues(alpha: 0.45)),
                  const SizedBox(height: 8),
                  Text(
                    'Seleccionar nueva imagen',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF052B67).withValues(alpha: 0.65)),
                  ),
                  const SizedBox(height: 2),
                  Text('JPG, PNG (máx. 5MB)',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _showUrlField = !_showUrlField),
          child: Row(
            children: [
              Icon(
                _showUrlField ? CupertinoIcons.chevron_up : CupertinoIcons.link,
                size: 13, color: const Color(0xFF052B67)),
              const SizedBox(width: 6),
              Text(
                _showUrlField ? 'Ocultar campo de URL' : 'O ingresa una URL de imagen',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF052B67),
                    fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (_showUrlField) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _imageUrlController,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1C2532)),
            decoration:
                panelInputDecoration(hint: 'https://ejemplo.com/portada.jpg')
                    .copyWith(
              prefixIcon: const Icon(CupertinoIcons.link,
                  size: 16, color: Color(0xFF6B7280)),
            ),
            onChanged: (_) => setState(() => _clearUrl = false),
          ),
        ],
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
        height: 160,
        color: const Color(0xFFF8FAFC),
        child: const Center(
            child: Icon(CupertinoIcons.photo,
                color: Color(0xFFCCCCCC), size: 40)),
      );
}

// ─── Función de apertura ──────────────────────────────────────────────────────
void showEditBookDialog(
  BuildContext context,
  Book book, {
  required void Function(Book) onUpdate,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Editar libro',
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: Align(
          alignment: Alignment.centerRight,
          child: EditBookDialog(book: book, onUpdate: onUpdate),
        ),
      );
    },
  );
}