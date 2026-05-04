import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

InputDecoration panelInputDecoration({String? hint}) => InputDecoration(
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

/// Label con asterisco opcional
Widget panelLabel(String label, {bool required = true}) {
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
          fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
      children: const [
        TextSpan(
            text: ' *',
            style:
                TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

/// Wrapper label + campo
Widget panelLabeledField({
  required String label,
  required Widget child,
  bool required = true,
}) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        panelLabel(label, required: required),
        const SizedBox(height: 5),
        child,
      ],
    );

/// Campo de texto completo
Widget panelField(
  String label,
  TextEditingController ctrl, {
  String? hint,
  bool required = true,
  bool onlyDigits = false,
  int? maxLength,
  String? Function(String?)? validator,
}) =>
    panelLabeledField(
      label: label,
      required: required,
      child: TextFormField(
        controller: ctrl,
        keyboardType: onlyDigits ? TextInputType.number : TextInputType.text,
        inputFormatters: [
          if (onlyDigits) FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1C2532),
            fontWeight: FontWeight.w500),
        decoration: panelInputDecoration(hint: hint),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obligatorio'
                    : null
                : null),
      ),
    );