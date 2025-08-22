import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final String? Function(String?)? validator;
  final IconData icon;
  final TextInputType keyboardType;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.validator,
    required this.icon,
    required this.keyboardType,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? _obscure : false,
        cursorColor: const Color.fromRGBO(0, 0, 0, 1),
        style: const TextStyle(
          color: Color.fromRGBO(47, 65, 87, 1),
          fontFamily: 'Roboto',
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Color.fromRGBO(47, 65, 87, 1)),
          prefixIcon: Icon(widget.icon, color: const Color.fromARGB(255, 21, 49, 94)),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color.fromRGBO(47, 65, 87, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(47, 65, 87, 1), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(36, 34, 34, 0.4), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: const Color.fromRGBO(255, 255, 255, 0.05),
        ),
        validator: widget.validator,
      ),
    );
  }
}