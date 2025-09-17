import 'dart:ui';
import 'package:flutter/material.dart';
import '../../viewmodels/login_vm.dart';
import '../global/dialog.dart';

Future<void> showPasswordResetDialog(BuildContext context, LoginVM viewModel) async {
  final TextEditingController resetController = TextEditingController();

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color.fromRGBO(10, 10, 10, 0.102)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Recuperar Contraseña',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: resetController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final navigator = Navigator.of(dialogContext);

                        final message = await viewModel.sendPasswordResetEmail(
                          resetController.text.trim(),
                        );

                        if (navigator.canPop()) navigator.pop();

                        showDialog(
                          context: context,
                          builder: (_) => CustomDialog(
                            title: "Correo enviado",
                            message: message,
                            color: Colors.green,
                            icon: Icons.check_circle,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(26, 61, 99, 1),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shadowColor: const Color.fromRGBO(26, 61, 99, 0.4),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: const Text(
                        "Enviar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
