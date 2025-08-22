import 'package:flutter/material.dart';
import 'dart:ui';

class BackgroundCircles extends StatelessWidget {
  const BackgroundCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: 50,
          child: _buildCircle(200, Colors.red),
        ),
        Positioned(
          bottom: 150,
          right: 80,
          child: _buildCircle(180, Colors.green),
        ),
        Positioned(
          top: 300,
          right: 200,
          child: _buildCircle(150, Colors.purple),
        ),
        Positioned(
          top: 50,
          left: 1200,
          child: _buildCircle(200, Colors.red),
        ),
        Positioned(
          bottom: 150,
          right: 800,
          child: _buildCircle(180, Colors.green),
        ),
        Positioned(
          top: 400,
          right: 1000,
          child: _buildCircle(150, Colors.purple),
        ),
      ],
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
    );
  }
}
