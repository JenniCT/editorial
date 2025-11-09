//=========================== IMPORTACIONES PRINCIPALES ===========================//
// IMPORTACION DE FLUTTER PARA UI Y NAVEGACION
import 'package:flutter/material.dart';

// IMPORTACION DE VISTA-MODELO LOGIN PARA ACCESO A FUNCIONES DE AUTENTICACION
import '../../viewmodels/login/login_vm.dart';

// IMPORTACION DE DIALOGOS Y BOTONES PERSONALIZADOS
import '../global/dialog.dart';
import '../../widgets/login/button.dart'; // BOTON ESTILIZADO PARA ACCIONES

//=========================== FUNCION DIALOGO RECUPERAR CONTRASEÑA ===========================//
// FUNCION RESPONSABLE DE MOSTRAR UN DIALOGO CLARO Y EMOCIONALMENTE GUIADO
Future<void> showPasswordResetDialog(BuildContext context, LoginVM viewModel) async {
  // CONTROLADOR DE TEXTO PARA INGRESO DE CORREO
  final TextEditingController resetController = TextEditingController();

  return showDialog(
    context: context,
    barrierDismissible: true, // PERMITE CERRAR AL HACER CLICK FUERA DEL DIALOGO
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent, // FONDO TRANSPARENTE PARA ENFOQUE EN CARD
        insetPadding: const EdgeInsets.all(24),
        child: LayoutBuilder(builder: (context, constraints) {
          // AJUSTE DE ANCHO MAXIMO PARA RESPONSIVE
          double maxWidth = constraints.maxWidth > 500 ? 500 : constraints.maxWidth * 0.9;
          return Center(
            child: Stack(
              children: [
                //=========================== CONTENEDOR PRINCIPAL ===========================//
                Container(
                  width: maxWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.95), // FONDO SUAVE, LEVE TRANSPARENCIA
                    borderRadius: BorderRadius.circular(20), // BORDES SUAVES PARA EXPERIENCIA AMIGABLE
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.1), // SOMBRA LEVE PARA PROFUNDIDAD
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //=========================== ICONO/LOGO ===========================//
                        SizedBox(
                          width: constraints.maxWidth <= 767 ? 80 : 120, // ADAPTA TAMAÑO EN MOVILES
                          child: Image.asset('assets/images/garra.png'),
                        ),
                        const SizedBox(height: 16),
                        //=========================== TITULO ===========================//
                        const Text(
                          'Recuperar contraseña',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 28,
                            color: Color(0xFF1E2A45),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        //=========================== TEXTO EXPLICATIVO ===========================//
                        const Text(
                          'Ingresa el correo asociado a tu cuenta para recibir el enlace de recuperación',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xFF352E35),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        //=========================== INPUT EMAIL ===========================//
                        TextField(
                          controller: resetController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Color(0xFF1E1E1E),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            hintText: 'Correo electrónico',
                            hintStyle: const TextStyle(
                              color: Color(0xFF352E35),
                              fontFamily: 'Roboto',
                            ),
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF51617A)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFC5D0E0), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF3056D3), width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        //=========================== BOTON ENVIAR ===========================//
                        LoginButton(
                          text: 'Enviar enlace',
                          onTap: () async {
                            final navigator = Navigator.of(dialogContext);

                            // ENVIO DE CORREO DE RECUPERACION
                            final message = await viewModel.sendPasswordResetEmail(
                              resetController.text.trim(),
                            );

                            // CIERRA DIALOGO SI ES POSIBLE
                            if (navigator.canPop()) navigator.pop();

                            // MUESTRA TOAST CON MENSAJE DE RESULTADO
                            CustomToast(
                              title: message.contains('error') ? 'Error' : 'Correo enviado',
                              message: message,
                              color: message.contains('error') ? Colors.red : Colors.green,
                              icon: message.contains('error') ? Icons.error : Icons.check_circle,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        //=========================== IMAGEN ADICIONAL PARA MOVILES ===========================//
                        if (constraints.maxWidth <= 767)
                          SizedBox(
                            height: 120,
                            child: Image.asset('assets/ocelote.png'),
                          ),
                      ],
                    ),
                  ),
                ),
                //=========================== BOTON CERRAR ===========================//
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF51617A), size: 28),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // CIERRA EL DIALOGO
                    },
                    tooltip: 'Cerrar',
                    autofocus: true,
                  ),
                ),
              ],
            ),
          );
        }),
      );
    },
  );
}
