import 'dart:ui';
import 'package:flutter/material.dart';


class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final int durationSeconds;


  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    this.durationSeconds = 4, 

  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      backgroundColor: Colors.transparent,
      elevation: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(51, 0, 0, 0),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color.fromARGB(26, 10, 10, 10)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 40),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(fontSize: 22, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}