import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// WIDGETS
import '../../widgets/addbook/image_picker_field.dart';
import '../../widgets/global/textfield.dart';

// MODELO Y VIEWMODEL DE BOOK
import '../../models/book_m.dart';
import '../../viewmodels/acervo/acervo_vm.dart'; // VM adaptada para manejar acervo dentro de books

class AddAcervoDialog extends StatefulWidget {
  final Function(Book) onAdd;

  const AddAcervoDialog({required this.onAdd, super.key});

  @override
  State<AddAcervoDialog> createState() => _AddAcervoDialogState();
}

class _AddAcervoDialogState extends State<AddAcervoDialog> {
  final _formKey = GlobalKey<FormState>();
  final AcervoViewModel _viewModel = AcervoViewModel();

  String _selectedAreaConocimiento = 'Sin definir';
  File? _selectedImage;

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
  final TextEditingController _precioController = TextEditingController();

  final List<String> _areasConocimiento = [
    'Sin definir',
    'Físico-Matemáticas y Ciencias de la Tierra',
    'Biología y Química',
    'Medicina y Ciencias de la Salud',
    'Humanidades y Ciencias de la Conducta',
    'Ciencias Sociales',
    'Biotecnología y Ciencias Agropecuarias',
    'Ingenierías',
    'Artes'
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveAcervo() async {
    if (_formKey.currentState!.validate()) {
      final copias = int.tryParse(_copiasController.text) ?? 1;

      final book = Book(
        imagenFile: _selectedImage,
        imagenUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text.trim() : null,
        titulo: _tituloController.text.trim(),
        subtitulo: _subtituloController.text.isNotEmpty ? _subtituloController.text.trim() : null,
        autor: _autorController.text.trim(),
        editorial: _editorialController.text.trim(),
        coleccion: _coleccionController.text.isNotEmpty ? _coleccionController.text.trim() : null,
        anio: int.tryParse(_anioController.text) ?? 0,
        isbn: _isbnController.text.isNotEmpty ? _isbnController.text.trim() : null,
        edicion: int.tryParse(_edicionController.text) ?? 1,
        copias: copias,
        estante: 0, // acervo
        almacen: copias, // acervo
        areaConocimiento: _selectedAreaConocimiento,
        estado: false, // acervo
        fechaRegistro: DateTime.now(),
        registradoPor: FirebaseAuth.instance.currentUser?.uid ?? 'desconocido',
      );

      await _viewModel.addAcervo(book, context);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 600,
            height: 700,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(19, 38, 87, 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color.fromRGBO(47, 65, 87, 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Agrega nuevo libro al acervo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ImagePickerField(
                              selectedImage: _selectedImage,
                              imageUrlController: _imageUrlController,
                              onPickImage: _pickImage,
                              onClearImage: () => setState(() => _selectedImage = null),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(controller: _tituloController, label: 'Título', validator: (value) => value == null || value.isEmpty ? 'El título es obligatorio' : null),
                            CustomTextField(controller: _autorController, label: 'Autor', validator: (value) => value == null || value.isEmpty ? 'El autor es obligatorio' : null),
                            CustomTextField(controller: _editorialController, label: 'Editorial', validator: (value) => value == null || value.isEmpty ? 'La editorial es obligatoria' : null),
                            CustomTextField(controller: _anioController, label: 'Año', isNumeric: true, validator: (value) {
                              if (value == null || value.isEmpty) return 'El año es obligatorio';
                              if (int.tryParse(value) == null) return 'Debe ser un número válido';
                              return null;
                            }),
                            CustomTextField(controller: _coleccionController, label: 'Colección', isOptional: true),
                            CustomTextField(controller: _subtituloController, label: 'Subtítulo', isOptional: true),
                            CustomTextField(controller: _isbnController, label: 'ISBN', isOptional: true),
                            CustomTextField(controller: _edicionController, label: 'Edición', isNumeric: true, isOptional: true),
                            CustomTextField(controller: _copiasController, label: 'Número de copias', isNumeric: true),
                            CustomTextField(controller: _precioController, label: 'Precio', isNumeric: true),
                            const SizedBox(height: 16),
                            // Dropdown de área de conocimiento
                            FormField<String>(
                              initialValue: _selectedAreaConocimiento,
                              validator: (value) => value == null || value.isEmpty ? 'Selecciona un área de conocimiento' : null,
                              builder: (fieldState) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: _selectedAreaConocimiento,
                                      decoration: InputDecoration(
                                        labelText: 'Área de conocimiento',
                                        labelStyle: const TextStyle(color: Colors.white),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white70)),
                                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                                      ),
                                      dropdownColor: const Color.fromRGBO(30, 50, 100, 1),
                                      style: const TextStyle(color: Colors.white),
                                      isExpanded: true,
                                      items: _areasConocimiento.map((area) => DropdownMenuItem(value: area, child: Text(area, overflow: TextOverflow.ellipsis))).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAreaConocimiento = value ?? 'Sin definir';
                                          fieldState.didChange(value);
                                        });
                                      },
                                    ),
                                    if (fieldState.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(fieldState.errorText ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(240, 91, 84, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saveAcervo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Agregar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showAddAcervoDialog(BuildContext context, Function(Book) onAdd) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Agregar libro al acervo',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => const SizedBox(),
    transitionBuilder: (context, animation, _, _) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return ScaleTransition(scale: curvedAnimation, child: AddAcervoDialog(onAdd: onAdd));
    },
  );
}
