import 'dart:ui';
import 'package:flutter/material.dart';

class CardBackground extends StatelessWidget {
  final Widget child;

  const CardBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
