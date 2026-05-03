import 'dart:io';
import 'package:editorial/models/book_m.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../viewmodels/book/book_vm.dart';

// ─── PAINTER PARA BORDE PUNTEADO ─────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double borderRadius;

  const _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.gapLength = 4,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(_createDashedPath(path), paint);
  }

  Path _createDashedPath(Path source) {
    final dashPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── WIDGET PRINCIPAL ─────────────────────────────────────────────────────────

class AddBookDialog extends StatefulWidget {
  final Function(Book) onAdd;

  const AddBookDialog({required this.onAdd, super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final BookViewModel _viewModel = BookViewModel();

  String _selectedAreaConocimiento = '';
  File? _selectedImage;
  Uint8List? _imageBytes; // PARA PREVISUALIZACIÓN CROSS-PLATFORM
  bool _isUpdating = false;
  bool _showUrlField = false;

  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _subtituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _editorialController = TextEditingController();
  final TextEditingController _coleccionController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _edicionController = TextEditingController();
  final TextEditingController _copiasController = TextEditingController();
  final TextEditingController _estanteController = TextEditingController();
  final TextEditingController _almacenController = TextEditingController();

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
    
     _editorialController.text = 'Dirección Editorial';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _copiasController.addListener(_onCopiasChanged);
    _estanteController.addListener(_onEstanteChanged);
    _almacenController.addListener(_onAlmacenChanged);
  }

  @override
  void dispose() {
    _animController.dispose();
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

  // ─── IMAGEN ───────────────────────────────────────────────────────────────

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

  // ─── GUARDAR ──────────────────────────────────────────────────────────────

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      imagenFile: _selectedImage,
      // LA URL SOLO SE USA SI NO HAY ARCHIVO SELECCIONADO
      imagenUrl: _selectedImage == null && _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text.trim()
          : null,
      titulo: _tituloController.text.trim(),
      subtitulo: _subtituloController.text.isNotEmpty
          ? _subtituloController.text.trim()
          : null,
      autor: _autorController.text.trim(),
      editorial: _editorialController.text.trim(),
      coleccion: _coleccionController.text.isNotEmpty
          ? _coleccionController.text.trim()
          : null,
      anio: int.tryParse(_anioController.text) ?? 0,
      isbn:
          _isbnController.text.isNotEmpty ? _isbnController.text.trim() : null,
      edicion: int.tryParse(_edicionController.text) ?? 1,
      estante: int.tryParse(_estanteController.text) ?? 0,
      almacen: int.tryParse(_almacenController.text) ?? 0,
      copias: int.tryParse(_copiasController.text) ?? 0,
      areaConocimiento: _selectedAreaConocimiento.isEmpty
          ? 'Sin definir'
          : _selectedAreaConocimiento,
      estado: true,
      fechaRegistro: DateTime.now(),
      registradoPor:
          FirebaseAuth.instance.currentUser?.uid ?? 'desconocido',
    );

    // EL VIEWMODEL SE ENCARGA DE CERRAR EL PANEL AL TERMINAR CON ÉXITO
    await _viewModel.addBook(book, context);
  }

  // ─── VALIDACIONES STOCK ───────────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 2),
    ));
  }

  void _onCopiasChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    final copias = int.tryParse(_copiasController.text) ?? 0;
    final almacen = int.tryParse(_almacenController.text) ?? 0;
    if (almacen > copias) {
      _showError('Almacén no puede ser mayor que el número total de copias');
      _almacenController.text = copias.toString();
      _estanteController.text = '0';
    } else {
      final estante = copias - almacen;
      if (estante >= 0) _estanteController.text = estante.toString();
    }
    _isUpdating = false;
  }

  void _onEstanteChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    final copias = int.tryParse(_copiasController.text) ?? 0;
    final estante = int.tryParse(_estanteController.text) ?? 0;
    if (estante > copias) {
      _showError('Estante no puede ser mayor que el número total de copias');
      _estanteController.text = copias.toString();
      _almacenController.text = '0';
    } else {
      final almacen = copias - estante;
      if (almacen >= 0) _almacenController.text = almacen.toString();
    }
    _isUpdating = false;
  }

  void _onAlmacenChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    final copias = int.tryParse(_copiasController.text) ?? 0;
    final almacen = int.tryParse(_almacenController.text) ?? 0;
    if (almacen > copias) {
      _showError('Almacén no puede ser mayor que el número total de copias');
      _almacenController.text = copias.toString();
      _estanteController.text = '0';
    } else {
      final estante = copias - almacen;
      if (estante >= 0) _estanteController.text = estante.toString();
    }
    _isUpdating = false;
  }

  // ─── HELPERS DE ESTILO ────────────────────────────────────────────────────

  Widget _labelText(String label, {bool required = true}) {
    if (!required) {
      return Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280)));
    }
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280)),
        children: const [
          TextSpan(
              text: ' *',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEEF0F4))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEEF0F4))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFF052B67), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5)),
      errorStyle: const TextStyle(fontSize: 10, height: 1),
    );
  }

  Widget _labeledField({
    required String label,
    required Widget child,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelText(label, required: required),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool required = true,
    bool onlyDigits = false,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return _labeledField(
      label: label,
      required: required,
      child: TextFormField(
        controller: ctrl,
        keyboardType:
            onlyDigits ? TextInputType.number : TextInputType.text,
        inputFormatters: [
          if (onlyDigits) FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1C2532),
            fontWeight: FontWeight.w500),
        decoration: _inputDecoration(hint: hint),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obligatorio'
                    : null
                : null),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C2532))),
      );

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(color: Color(0xFFEEEEEE), height: 1),
      );

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: const Color.fromRGBO(0, 0, 0, 0.45)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 480,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 32,
                      offset: Offset(-8, 0),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(24, 20, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageSection(),
                              _divider(),
                              _buildIdentificacionSection(),
                              _divider(),
                              _buildPublicacionSection(),
                              _divider(),
                              _buildStockSection(),
                              _divider(),
                              _buildClasificacionSection(),
                            ],
                          ),
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF052B67),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(CupertinoIcons.book_fill,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Agregar nuevo libro',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2532)),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ─── IMAGEN ───────────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    final hasFile = _imageBytes != null;
    final urlText = _imageUrlController.text.trim();
    final hasUrl = urlText.isNotEmpty && urlText.startsWith('http');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Imagen del libro'),

        if (hasFile) ...[
          // PREVISUALIZACIÓN CON BYTES (funciona en web y móvil)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _imageBytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
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
        ] else if (hasUrl) ...[
          // PREVISUALIZACIÓN DE URL
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              urlText,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _imagePlaceholder(),
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
        ] else ...[
          // ZONA DE CARGA
          GestureDetector(
            onTap: _pickImage,
            child: CustomPaint(
              painter: _DashedBorderPainter(
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
                        color: const Color(0xFF052B67)
                            .withValues(alpha: 0.45)),
                    const SizedBox(height: 8),
                    Text(
                      'Arrastra una imagen aquí',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF052B67)
                              .withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'o haz clic para seleccionar · JPG, PNG (máx. 5MB)',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // TOGGLE URL
          GestureDetector(
            onTap: () => setState(() => _showUrlField = !_showUrlField),
            child: Row(
              children: [
                Icon(
                  _showUrlField
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.link,
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
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF1C2532)),
              decoration: _inputDecoration(
                      hint: 'https://ejemplo.com/portada.jpg')
                  .copyWith(
                prefixIcon: const Icon(CupertinoIcons.link,
                    size: 16, color: Color(0xFF6B7280)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
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

  // ─── IDENTIFICACIÓN ───────────────────────────────────────────────────────

  Widget _buildIdentificacionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Identificación'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _field('Título', _tituloController,
                    hint: 'Ingrese el título del libro')),
            const SizedBox(width: 12),
            Expanded(
                child: _field('Subtítulo', _subtituloController,
                    hint: 'Subtítulo (opcional)', required: false)),
          ],
        ),
        const SizedBox(height: 12),
        _field('Autor(es)', _autorController,
            hint: 'Ingrese el nombre del autor'),
        const SizedBox(height: 12),
        _field('ISBN', _isbnController,
            hint: 'Ej. 978-607-561-088-7', required: false),
      ],
    );
  }

  // ─── PUBLICACIÓN ──────────────────────────────────────────────────────────

  Widget _buildPublicacionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Publicación'),

        // EDITORIAL — campo de texto libre (no dropdown ni autocomplete)
        _field('Editorial', _editorialController,
            hint: 'Ej. Dirección Editorial'),
        const SizedBox(height: 12),

        _field('Colección', _coleccionController,
            hint: 'Nombre de la colección', required: false),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AÑO — solo 4 dígitos
            Expanded(
              child: _field('Año', _anioController,
                  hint: 'Ej. 2023',
                  onlyDigits: true,
                  maxLength: 4,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    final yr = int.tryParse(v);
                    if (yr == null ||
                        yr < 1000 ||
                        yr > DateTime.now().year + 1) {
                      return 'Año inválido';
                    }
                    return null;
                  }),
            ),
            const SizedBox(width: 12),
            // EDICIÓN — solo dígitos
            Expanded(
              child: _field('Edición', _edicionController,
                  hint: 'Ej. 1',
                  required: false,
                  onlyDigits: true),
            ),
          ],
        ),
      ],
    );
  }

  // ─── STOCK ────────────────────────────────────────────────────────────────

  Widget _buildStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Stock'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeledField(
                label: 'Número de copias',
                child: TextFormField(
                  controller: _copiasController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1C2532),
                      fontWeight: FontWeight.w500),
                  decoration: _inputDecoration(hint: '0'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Obligatorio'
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeledField(
                label: 'Estante',
                child: TextFormField(
                  controller: _estanteController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1C2532),
                      fontWeight: FontWeight.w500),
                  decoration: _inputDecoration(hint: '0'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Obligatorio'
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeledField(
                label: 'Almacén',
                child: TextFormField(
                  controller: _almacenController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1C2532),
                      fontWeight: FontWeight.w500),
                  decoration: _inputDecoration(hint: '0'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Obligatorio'
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── CLASIFICACIÓN ────────────────────────────────────────────────────────

  Widget _buildClasificacionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Clasificación'),
        _labeledField(
          label: 'Área de conocimiento',
          child: DropdownButtonFormField<String>(
            value: _selectedAreaConocimiento.isEmpty
                ? null
                : _selectedAreaConocimiento,
            decoration: _inputDecoration(hint: 'Seleccione el área'),
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
                    child:
                        Text(a, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedAreaConocimiento = v ?? ''),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Selecciona un área' : null,
          ),
        ),
      ],
    );
  }

  // ─── FOOTER ───────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1C2532),
              side: const BorderSide(color: Color(0xFFDDE3EE)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancelar',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _saveBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF052B67),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Guardar',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── FUNCIÓN DE APERTURA ──────────────────────────────────────────────────────

void showAddBookDialog(BuildContext context, Function(Book) onAdd) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Agregar libro',
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
          child: AddBookDialog(onAdd: onAdd),
        ),
      );
    },
  );
}