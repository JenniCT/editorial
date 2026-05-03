import 'package:flutter/material.dart';

class AppFormDivider extends StatelessWidget {
  const AppFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Color(0xFFEEEEEE),
        height: 1,
      ),
    );
  }
}