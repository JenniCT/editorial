import 'dart:io';

import 'package:editorial/models/book_m.dart';
import 'package:editorial/widgets/side_panel/dashed_border_painter.dart';
import 'package:editorial/widgets/side_panel/side_panel.dart';
import 'package:editorial/widgets/side_panel/side_panel_fields.dart';
import 'package:editorial/widgets/side_panel/side_panel_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../viewmodels/acervo/acervo_vm.dart';

class AddAcervoDialog extends StatefulWidget {
  final Function(Book) onAdd;

  const AddAcervoDialog({required this.onAdd, super.key});

  @override
  State<AddAcervoDialog> createState() => _AddAcervoDialogState();
}

class _AddAcervoDialogState extends State<AddAcervoDialog> {
  final _formKey = GlobalKey<FormState>();
  final AcervoViewModel _viewModel = AcervoViewModel();

  // ─── Estado ───────────────────────────────────────────────────────────────
  String _selectedAreaConocimiento = 'Sin definir';
  File? _selectedImage;
  Uint8List? _imageBytes;
  bool _showUrlField = false;

  // ─── Controllers ──────────────────────────────────────────────────────────
  final _imageUrlController  = TextEditingController();
  final _tituloController    = TextEditingController();
  final _subtituloController = TextEditingController();
  final _autorController     = TextEditingController();
  final _editorialController = TextEditingController();
  final _coleccionController = TextEditingController();
  final _anioController      = TextEditingController();
  final _isbnController      = TextEditingController();
  final _edicionController   = TextEditingController();
  final _copiasController    = TextEditingController();
  final _precioController    = TextEditingController();

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

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void dispose() {
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
    _precioController.dispose();
    super.dispose();
  }

  // ─── Imagen ───────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageBytes = bytes;
        _imageUrlController.clear();
        _showUrlField = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
      _imageUrlController.clear();
      _showUrlField = false;
    });
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────
  Future<void> _saveAcervo() async {
    if (!_formKey.currentState!.validate()) return;

    final copias = int.tryParse(_copiasController.text) ?? 1;

    final book = Book(
      imagenFile: _selectedImage,
      imagenUrl: _selectedImage == null && _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text.trim()
          : null,
      titulo:     _tituloController.text.trim(),
      subtitulo:  _subtituloController.text.isNotEmpty
          ? _subtituloController.text.trim()
          : null,
      autor:      _autorController.text.trim(),
      editorial:  _editorialController.text.trim(),
      coleccion:  _coleccionController.text.isNotEmpty
          ? _coleccionController.text.trim()
          : null,
      anio:       int.tryParse(_anioController.text) ?? 0,
      isbn:       _isbnController.text.isNotEmpty
          ? _isbnController.text.trim()
          : null,
      edicion:    int.tryParse(_edicionController.text) ?? 1,
      copias:     copias,
      estante:    0,       // acervo siempre en 0
      almacen:    copias,  // acervo va todo al almacén
      areaConocimiento: _selectedAreaConocimiento,
      estado:       false, // acervo
      fechaRegistro: DateTime.now(),
      registradoPor: FirebaseAuth.instance.currentUser?.uid ?? 'desconocido',
    );

    await _viewModel.addAcervo(book, context);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title: 'Agregar libro al acervo',
        headerIcon: CupertinoIcons.archivebox_fill,
        onSave: _saveAcervo,
        saveLabel: 'Agregar al acervo',
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ──────────────────────────────────────────────────────
            PanelSection(
              title: 'Imagen del libro',
              children: [_buildImageSection()],
            ),

            // ── Identificación ──────────────────────────────────────────────
            PanelSection(
              title: 'Identificación',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: panelField('Título', _tituloController,
                          hint: 'Ingrese el título del libro'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: panelField('Subtítulo', _subtituloController,
                          hint: 'Subtítulo (opcional)', required: false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                panelField('Autor(es)', _autorController,
                    hint: 'Ingrese el nombre del autor'),
                const SizedBox(height: 12),
                panelField('ISBN', _isbnController,
                    hint: 'Ej. 978-607-561-088-7', required: false),
              ],
            ),

            // ── Publicación ─────────────────────────────────────────────────
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
                      child: panelField(
                        'Año', _anioController,
                        hint: 'Ej. 2023',
                        onlyDigits: true,
                        maxLength: 4,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          final yr = int.tryParse(v);
                          if (yr == null || yr < 1000 || yr > DateTime.now().year + 1) {
                            return 'Año inválido';
                          }
                          return null;
                        },
                      ),
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

            // ── Stock / Precio ───────────────────────────────────────────────
            // NOTA: en acervo no hay estante/almacén manual, solo copias y precio
            PanelSection(
              title: 'Inventario',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: panelField(
                        'Número de copias', _copiasController,
                        hint: '1',
                        onlyDigits: true,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Obligatorio'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: panelField(
                        'Precio', _precioController,
                        hint: '0.00',
                        // precio permite decimales, no usamos onlyDigits
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          if (double.tryParse(v) == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Clasificación ────────────────────────────────────────────────
            PanelSection(
              title: 'Clasificación',
              showDividerAfter: false,
              children: [_buildClasificacionSection()],
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
    final hasUrl  = urlText.isNotEmpty && urlText.startsWith('http');

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

    if (hasUrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              urlText,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_,_, _) => _imagePlaceholder(),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _clearImage,
            icon: const Icon(Icons.close, size: 14),
            label: const Text('Quitar imagen'),
            style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(fontSize: 13)),
          ),
        ],
      );
    }

    // Sin imagen
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
                    'Arrastra una imagen aquí',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF052B67).withValues(alpha: 0.65)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'o haz clic para seleccionar · JPG, PNG (máx. 5MB)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Toggle URL
        GestureDetector(
          onTap: () => setState(() => _showUrlField = !_showUrlField),
          child: Row(
            children: [
              Icon(
                _showUrlField ? CupertinoIcons.chevron_up : CupertinoIcons.link,
                size: 13,
                color: const Color(0xFF052B67),
              ),
              const SizedBox(width: 6),
              Text(
                _showUrlField
                    ? 'Ocultar campo de URL'
                    : 'O ingresa una URL de imagen',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF052B67),
                    fontWeight: FontWeight.w600),
              ),
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
            onChanged: (_) => setState(() {}),
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

  // ─── Sección clasificación ────────────────────────────────────────────────
  Widget _buildClasificacionSection() {
    return panelLabeledField(
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
                value: a, child: Text(a, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (v) =>
            setState(() => _selectedAreaConocimiento = v ?? 'Sin definir'),
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Selecciona un área' : null,
      ),
    );
  }
}

// ─── Función de apertura ──────────────────────────────────────────────────────
void showAddAcervoDialog(BuildContext context, Function(Book) onAdd) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Agregar libro al acervo',
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
          child: AddAcervoDialog(onAdd: onAdd),
        ),
      );
    },
  );
}