import 'package:flutter/material.dart';
import 'app_text_field.dart';

class AppNumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool required;
  final int? maxLength;
  final String? Function(String?)? validator;

  const AppNumberField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.required = true,
    this.maxLength,
    this.validator,
  });

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint,
      required: required,
      maxLength: maxLength,
      validator: validator,
    );
  }
}