import 'dart:io';
import 'package:editorial/models/bookdata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddBookDialog extends StatefulWidget {
  final Function(BookData) onAdd;

  const AddBookDialog({required this.onAdd, Key? key}) : super(key: key);

  @override
  _AddBookDialogState createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _authorController = TextEditingController();
  final _editorialController = TextEditingController();
  final _collectionController = TextEditingController();
  final _yearController = TextEditingController();
  final _isbnController = TextEditingController();
  final _editionController = TextEditingController();
  final _copiesController = TextEditingController();
  final _priceController = TextEditingController();
  final _formatController = TextEditingController();

  // Imagen
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: _selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                height: 180,
                width: 120,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              height: 180,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_a_photo, size: 40),
            ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildTextField(_titleController, 'Título'),
        _buildTextField(_authorController, 'Autor'),
        _buildTextField(_editorialController, 'Editorial'),
        _buildTextField(_yearController, 'Año'),
        _buildTextField(_collectionController, 'Colección'),
        _buildTextField(_formatController, 'Formato'),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildTextField(_subtitleController, 'Subtítulo'),
        _buildTextField(_isbnController, 'ISBN'),
        _buildTextField(_editionController, 'Edición'),
        _buildTextField(_copiesController, 'Ejemplares'),
        _buildTextField(_priceController, 'Precio'),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes guardar los datos o enviarlos a tu backend
      Navigator.of(context).pop(); // Cierra el diálogo
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar libro'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLeftColumn()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRightColumn()),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}