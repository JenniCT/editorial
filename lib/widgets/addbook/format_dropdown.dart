import 'package:flutter/material.dart';

class FormatDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const FormatDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<String> formatos = ['Digital', 'Impreso', 'Ambos'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: formatos.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: 'Formato',
          labelStyle: const TextStyle(color: Colors.white),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(47, 65, 87, 1), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: const Color.fromRGBO(255, 255, 255, 0.05),
        ),
        dropdownColor: Colors.white,
        items: formatos
            .map((format) => DropdownMenuItem<String>(
                  value: format,
                  child: Text(format, style: const TextStyle(color: Colors.black)),
                ))
            .toList(),
        selectedItemBuilder: (_) {
          return formatos.map((format) {
            return Text(format, style: const TextStyle(color: Colors.white));
          }).toList();
        },
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}
