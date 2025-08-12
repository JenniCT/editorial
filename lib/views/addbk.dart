import 'dart:io';
import 'dart:ui';
import 'package:editorial/models/bookM.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


import '../widgets/addbook/image_picker_field.dart';
import '../widgets/addbook/custom_text_field.dart';
import '../widgets/addbook/format_dropdown.dart';

import '../viewmodels/bookVM.dart';

class AddBookDialog extends StatefulWidget {
  final Function(Book) onAdd;

  const AddBookDialog({required this.onAdd, Key? key}) : super(key: key);

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final BookViewModel _viewModel = BookViewModel();

  String _selectedFormat = 'Impreso';
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        
        imagenFile: null,

      
        imagenUrl: _imageUrlController.text.isNotEmpty
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
        isbn: _isbnController.text.isNotEmpty
            ? _isbnController.text.trim()
            : null,
        edicion: int.tryParse(_edicionController.text) ?? 1,
        copias: int.tryParse(_copiasController.text) ?? 1,
        precio: double.tryParse(_precioController.text) ?? 0.0,
        formato: _selectedFormat,
        estado: true,
        fechaRegistro: DateTime.now(),
      );

      await _viewModel.addBook(book);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Libro agregado con éxito")),
      );
      Navigator.pop(context);
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
                      'Agrega nuevo libro',
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: _tituloController,
                                        label: 'Título',
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El título es obligatorio';
                                          }
                                          return null;
                                        },
                                      ),
                                      CustomTextField(
                                        controller: _autorController,
                                        label: 'Autor',
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El autor es obligatorio';
                                          }
                                          return null;
                                        },
                                      ),
                                      CustomTextField(
                                        controller: _editorialController,
                                        label: 'Editorial',
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'La editorial es obligatoria';
                                          }
                                          return null;
                                        },
                                      ),
                                      CustomTextField(
                                        controller: _anioController,
                                        label: 'Año',
                                        isNumeric: true,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El año es obligatorio';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Debe ser un número válido';
                                          }
                                          return null;
                                        },
                                      ),
                                      CustomTextField(
                                        controller: _coleccionController,
                                        label: 'Colección',
                                        isOptional: true,
                                      ),
                                      FormField<String>(
                                        initialValue: _selectedFormat,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Selecciona un formato válido';
                                          }
                                          return null;
                                        },
                                        builder: (fieldState) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormatDropdown(
                                                value: _selectedFormat,
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    setState(() {
                                                      _selectedFormat = v;
                                                      fieldState.didChange(v);
                                                    });
                                                  }
                                                },
                                              ),
                                              if (fieldState.hasError)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    fieldState.errorText ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: _subtituloController,
                                        label: 'Subtítulo',
                                        isOptional: true,
                                      ),
                                      CustomTextField(
                                        controller: _isbnController,
                                        label: 'ISBN',
                                        isOptional: true,
                                      ),
                                      CustomTextField(
                                        controller: _edicionController,
                                        label: 'Edición',
                                        isNumeric: true,
                                        isOptional: true,
                                        validator: (value) {
                                          if (value != null && value.isNotEmpty) {
                                            if (int.tryParse(value) == null) {
                                              return 'Debe ser un número válido';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                      CustomTextField(
                                        controller: _copiasController,
                                        label: 'Número de copias',
                                        isNumeric: true,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El número de copias es obligatorio';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Debe ser un número válido';
                                          }
                                          return null;
                                        },
                                      ),
                                      CustomTextField(
                                        controller: _precioController,
                                        label: 'Precio',
                                        isNumeric: true,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El precio es obligatorio';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Debe ser un número válido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saveBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
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

void showAddBookDialog(BuildContext context, Function(Book) onAdd) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Agregar libro',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, animation, _, __) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return ScaleTransition(
        scale: curvedAnimation,
        child: AddBookDialog(onAdd: onAdd),
      );
    },
  );
}
