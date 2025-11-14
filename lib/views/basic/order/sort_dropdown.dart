import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  final String selectedOption;
  final List<String> options;
  final Function(String) onChanged;

  const SortDropdown({
    Key? key,
    required this.selectedOption,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedOption,
      icon: const Icon(Icons.arrow_drop_down),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
