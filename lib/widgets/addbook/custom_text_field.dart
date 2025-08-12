import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isOptional;
  final bool isNumeric;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.isOptional = false,
    this.isNumeric = false,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        cursorColor: Colors.white,
        style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.867)),
        decoration: InputDecoration(
          labelText: label,
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
        validator: validator, 
      ),
    );
  }
}
