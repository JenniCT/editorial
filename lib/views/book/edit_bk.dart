import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//MODELO
import '../../models/book_m.dart';
//VISTA-MODELO
import '../../viewmodels/book/book_vm.dart';
//WIDGETS
import '../../widgets/addbook/image_picker_field.dart';
import '../../widgets/global/textfield.dart';


class EditBookDialog extends StatefulWidget {
  final Book book;
  final Function(Book) onUpdate;

  const EditBookDialog({super.key, required this.book, required this.onUpdate});

  @override
  State<EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<EditBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final BookViewModel _viewModel = BookViewModel();

  String _selectedAreaConocimiento = 'Sin definir';
  File? _selectedImage;

  late TextEditingController _imageUrlController;
  late TextEditingController _tituloController;
  late TextEditingController _subtituloController;
  late TextEditingController _autorController;
  late TextEditingController _editorialController;
  late TextEditingController _coleccionController;
  late TextEditingController _anioController;
  late TextEditingController _isbnController;
  late TextEditingController _edicionController;
  late TextEditingController _copiasController;
  late TextEditingController _estanteController;
  late TextEditingController _almacenController;

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

    _selectedAreaConocimiento = b.areaConocimiento;
    _imageUrlController = TextEditingController(text: b.imagenUrl);
    _tituloController = TextEditingController(text: b.titulo);
    _subtituloController = TextEditingController(text: b.subtitulo ?? '');
    _autorController = TextEditingController(text: b.autor);
    _editorialController = TextEditingController(text: b.editorial);
    _coleccionController = TextEditingController(text: b.coleccion ?? '');
    _anioController = TextEditingController(text: b.anio.toString());
    _isbnController = TextEditingController(text: b.isbn ?? '');
    _edicionController = TextEditingController(text: b.edicion.toString());
    _copiasController = TextEditingController(text: b.copias.toString());
    _estanteController = TextEditingController(text: b.estante.toString());
    _almacenController = TextEditingController(text: b.almacen.toString());
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
    _estanteController.dispose();
    _almacenController.dispose();
    super.dispose();
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      final updatedBook = widget.book.copyWith(
        imagenFile: _selectedImage, // <--- PASAMOS LA IMAGEN SELECCIONADA
        imagenUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
        titulo: _tituloController.text,
        subtitulo: _subtituloController.text.isNotEmpty ? _subtituloController.text : null,
        autor: _autorController.text,
        editorial: _editorialController.text,
        coleccion: _coleccionController.text.isNotEmpty ? _coleccionController.text : null,
        anio: int.tryParse(_anioController.text) ?? 0,
        isbn: _isbnController.text.isNotEmpty ? _isbnController.text : null,
        edicion: int.tryParse(_edicionController.text) ?? 1,
        copias: int.tryParse(_copiasController.text) ?? 1,
        estante: int.tryParse(_estanteController.text) ?? 0,
        almacen: int.tryParse(_almacenController.text) ?? 0,
        areaConocimiento: _selectedAreaConocimiento,
      );

      // Actualizar en la base de datos
      await _viewModel.editBook(updatedBook, context);

      // Actualizar la UI del padre
      widget.onUpdate(updatedBook);

      // Cerrar el diálogo
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
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
                      'Editar Libro',
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
                              onClearImage: () =>
                                  setState(() => _selectedImage = null),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: _tituloController,
                                        label: 'Título',
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obligatorio' : null,
                                      ),
                                      CustomTextField(
                                        controller: _autorController,
                                        label: 'Autor',
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obligatorio' : null,
                                      ),
                                      CustomTextField(
                                        controller: _editorialController,
                                        label: 'Editorial',
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obligatorio' : null,
                                      ),
                                      CustomTextField(
                                        controller: _anioController,
                                        label: 'Año',
                                        isNumeric: true,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obligatorio' : null,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: DropdownButtonFormField<String>(
                                                  initialValue: _selectedAreaConocimiento,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Área de conocimiento',
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Colors
                                                                    .white70,
                                                              ),
                                                        ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                  47,
                                                                  65,
                                                                  87,
                                                                  1,
                                                                ),
                                                          ),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.red,
                                                          ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Colors
                                                                    .redAccent,
                                                              ),
                                                        ),
                                                  ),
                                                  dropdownColor:
                                                      const Color.fromRGBO(
                                                        30,
                                                        50,
                                                        100,
                                                        1,
                                                      ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  isExpanded: true,
                                                  items: _areasConocimiento.map(
                                                    (area) {
                                                      return DropdownMenuItem(
                                                        value: area,
                                                        child: Text(
                                                          area,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    },
                                                  ).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedAreaConocimiento =
                                                          value ??
                                                          'Sin definir';
                                                      fieldState.didChange(
                                                        value,
                                                      );
                                                    });
                                                  },
                                                ),
                                              ),
                                              if (fieldState.hasError)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
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
                                      ),
                                      CustomTextField(
                                        controller: _copiasController,
                                        label: 'Copias',
                                        isNumeric: true,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obligatorio' : null,
                                      ),
                                      CustomTextField(
                                        controller: _estanteController,
                                        label: 'Estante',
                                        isNumeric: true,
                                      ),
                                      CustomTextField(
                                        controller: _almacenController,
                                        label: 'Almacén',
                                        isNumeric: true,
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
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              240,
                              91,
                              84,
                              1,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _updateBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Guardar'),
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

void showEditBookDialog(
  BuildContext context,
  Book book,
  Function(Book) onUpdate,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Editar libro',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => const SizedBox(),
    transitionBuilder: (context, animation, _, _) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: EditBookDialog(book: book, onUpdate: onUpdate),
      );
    },
  );
}