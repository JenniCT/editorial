import 'dart:io';
import 'dart:ui';
import 'package:editorial/models/book_m.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
//WIDGETS
import '../../widgets/addbook/image_picker_field.dart';
import '../../widgets/global/textfield.dart';

import '../../viewmodels/book/book_vm.dart';

class AddBookDialog extends StatefulWidget {
  final Function(Book) onAdd;

  const AddBookDialog({required this.onAdd, super.key});
  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final BookViewModel _viewModel = BookViewModel();

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
    'Artes'
  ];

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
        estante: int.tryParse(_estanteController.text) ?? 0,
        almacen: int.tryParse(_almacenController.text) ?? 0,
        copias: int.tryParse(_copiasController.text) ?? 0,
        areaConocimiento: _selectedAreaConocimiento,
        estado: true,
        fechaRegistro: DateTime.now(),
        registradoPor: FirebaseAuth.instance.currentUser?.uid ?? 'desconocido',
      );

      // 🔥 SOLO LLAMAR AL VIEWMODEL - ÉL SE ENCARGA DE CERRAR EL DIÁLOGO
      await _viewModel.addBook(book, context);
      
      // 🔥 QUITAR ESTA LÍNEA:
      // if (mounted) Navigator.pop(context);
    }
  }
  bool _isUpdating = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
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
      if (estante >= 0) {
        _estanteController.text = estante.toString();
      }
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
      if (almacen >= 0) {
        _almacenController.text = almacen.toString();
      }
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
      if (estante >= 0) {
        _estanteController.text = estante.toString();
      }
    }

    _isUpdating = false;
  }

  @override
  void initState() {
    super.initState();
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
            height: 750,
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
                              //TITULO
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: _tituloController,
                                        label: 'Título',
                                        validator: (value) =>
                                            value == null || value.trim().isEmpty
                                                ? 'El título es obligatorio'
                                                : null,
                                      ),
                                      // AUTOR
                                      CustomTextField(
                                        controller: _autorController,
                                        label: 'Autor',
                                        validator: (value) =>
                                            value == null || value.trim().isEmpty
                                                ? 'El autor es obligatorio'
                                                : null,
                                      ),
                                      // EDITORIAL
                                      CustomTextField(
                                        controller: _editorialController,
                                        label: 'Editorial',
                                        validator: (value) =>
                                            value == null || value.trim().isEmpty
                                                ? 'La editorial es obligatoria'
                                                : null,
                                      ),
                                      // AÑO
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
                                      // ÁREA DE CONOCIMIENTO
                                      FormField<String>(
                                        initialValue: _selectedAreaConocimiento,
                                        validator: (value) => value == null || value.isEmpty ? 'Selecciona un área de conocimiento válida' : null,
                                        builder: (fieldState) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: DropdownButtonFormField<String>(
                                                  initialValue: _selectedAreaConocimiento,
                                                  decoration: InputDecoration(
                                                    labelText: 'Área de conocimiento',
                                                    labelStyle: const TextStyle(color: Colors.white),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: Colors.white70),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: Color.fromRGBO(47, 65, 87, 1)),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: Colors.red),
                                                    ),
                                                    focusedErrorBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: Colors.redAccent),
                                                    ),
                                                  ),
                                                  dropdownColor: const Color.fromRGBO(30, 50, 100, 1),
                                                  style: const TextStyle(color: Colors.white),
                                                  isExpanded: true,
                                                  items: _areasConocimiento.map((area) {
                                                    return DropdownMenuItem(
                                                      value: area,
                                                      child: Text(area, overflow: TextOverflow.ellipsis),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedAreaConocimiento = value ?? 'Sin definir';
                                                      fieldState.didChange(value);
                                                    });
                                                  },
                                                ),
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
                                //SUBTITULO
                                Expanded(
                                  child: Column(
                                    children: [
                                      // SUBTITULO
                                      CustomTextField(
                                        controller: _subtituloController,
                                        label: 'Subtítulo',
                                        isOptional: true,
                                      ),
                                      // ISBN
                                      CustomTextField(
                                        controller: _isbnController,
                                        label: 'ISBN',
                                        isOptional: true,
                                      ),
                                      // EDICION
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
                                      // COPIAS
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
                                      const SizedBox(height: 8),
                                      // ESTANTE
                                      CustomTextField(
                                        controller: _estanteController,
                                        label: 'Estante',
                                        isNumeric: true,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El estante es obligatorio';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Debe ser un número válido';
                                          }
                                          return null;
                                        },
                                      ),
                                      // ALMACÉN
                                      CustomTextField(
                                        controller: _almacenController,
                                        label: 'Almacén',
                                        isNumeric: true,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El almacén es obligatorio';
                                          }
                                          if (int.tryParse(value) == null) {
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
    pageBuilder: (_, _, _) => const SizedBox(),
    transitionBuilder: (context, animation, _, _) {
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
