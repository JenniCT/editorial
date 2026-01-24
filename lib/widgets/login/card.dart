//=========================== IMPORTACIONES DEL MODULO ===========================//
// ORGANIZACION DE DEPENDENCIAS PARA MANTENER CLARIDAD ESTRUCTURAL EN EL SISTEMA DE LOGIN

// BASE DE WIDGETS DE FLUTTER
import 'package:flutter/material.dart';

// DIALOGO DE RECUPERACION DE CONTRASENA
import '../../widgets/login/password_reset.dart';

// VISTA-MODELO DE LOGIN QUE MANEJA ESTADO, VALIDACION Y ACCIONES
import '../../viewmodels/login/login_vm.dart';

// CAMPOS DE TEXTO PERSONALIZADOS DEL LOGIN
import 'input.dart';

// BOTON PRINCIPAL DE ACCESO
import 'button.dart';

// IDENTIDAD VISUAL Y LOGOS INSTITUCIONALES
import 'logos.dart';

//=========================== TARJETA VISUAL DEL LOGIN ===========================//
// ESTA TARJETA ES EL ESPACIO CENTRAL DE LA INTERACCION. OFRECE CONTENCION,
// JERARQUIA VISUAL Y ACCESO CLARO AL SISTEMA

class LoginCard extends StatelessWidget {
  final LoginVM vm;       // VISTA-MODELO QUE CONTIENE LOGICA Y CONTROLADORES
  final bool desktop;     // DETERMINA ESTILO Y DIMENSION SEGUN DISPOSITIVO

  const LoginCard({
    super.key,
    required this.vm,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {

    //=========================== CONTENEDOR PRINCIPAL ===========================//
    // ESPACIO ACOTADO PARA CREAR UNA COMPOSICION LIMPIA Y SERENA
    return Container(
      constraints: BoxConstraints(maxWidth: desktop ? 520 : 420),

      // ESPACIADO INTERNO GENEROSO PARA AMPLITUD Y RESPIRACION VISUAL
      padding: const EdgeInsets.all(32),

      //=========================== ESTETICA DE LA TARJETA ===========================//
      // DEGRADADO SUAVE QUE TRANSMITE CALMA Y ESTABILIDAD INSTITUCIONAL
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F7FA), // TONO SUPERIOR CLARO
            Color(0xFFEAEFF5), // TONO INFERIOR QUE GENERA PROFUNDIDAD
          ],
        ),

        // BORDES REDONDEADOS PARA UNA IMPRONTA HUMANA Y CERCANA
        borderRadius: BorderRadius.circular(20),

        // SOMBRA SUAVE PARA ELEVAR LA TARJETA Y DAR PRESENCIA
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),

      //=========================== CONTENIDO INTERNO ===========================//
      child: Column(
        children: [

          // LOGOS OFICIALES PARA REFORZAR IDENTIDAD INSTITUCIONAL
          const LoginLogos(),
          const SizedBox(height: 32),

          //=========================== TITULO PRINCIPAL ===========================//
          // PRESENTACION FIRME Y PROFESIONAL DEL ACTO DE INGRESO
          const Text(
            'Iniciar sesion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 32,
              height: 1.25,
              color: Color(0xFF1B1F3B), // TONO AZUL PROFUNDO PARA AUTORIDAD Y SOBRIEDAD
            ),
          ),

          const SizedBox(height: 12),

          //=========================== TEXTO DE GUIA ===========================//
          // MENSAJE QUE CONTIENE Y UBICA EMOCIONALMENTE AL USUARIO
          const Text(
            'Accede a tu cuenta para continuar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF475569), // TONO NEUTRO PARA CALMA Y LEGIBILIDAD
            ),
          ),

          const SizedBox(height: 32),

          //=========================== CAMPO DE CORREO ===========================//
          // ENTRADA PRIMARIA DEL USUARIO, DISEÑADA PARA CLARIDAD Y PROXIMIDAD
          LoginInput(
            label: 'Correo electronico', 
            controller: vm.emailController,autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),

          //=========================== CAMPO DE CONTRASENA ===========================//
          // ENTRADA PROTEGIDA QUE PRIORIZA SEGURIDAD Y CONFIANZA
          LoginInput(
            label: 'Contraseña',
            controller: vm.passwordController,
            obscure: true,
            autofillHints: const [AutofillHints.password],
          ),

          const SizedBox(height: 12),

          //=========================== ACCESO A RECUPERACION ===========================//
          // ENLACE SUTIL PERO ACCESIBLE PARA RECONSTRUIR LA SEGURIDAD DE LA CUENTA
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => showPasswordResetDialog(context, vm),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
                    const SizedBox(height: 26),

          //=========================== BOTON PRINCIPAL DE ACCESO ===========================//
          // ACCION CENTRAL. CONFIRMA IDENTIDAD Y DA PASO AL SISTEMA
          LoginButton(
            text: 'Iniciar sesion',
            onTap: () {
              // VERIFICACION BASICA PARA EVITAR ERRORES Y CONFUSION EN EL USUARIO
              if (vm.emailController.text.isEmpty || vm.passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos')),
                );
                return;
              }

              // ACCION PRINCIPAL DE AUTENTICACION
              vm.login(context);
            },
          ),

          const SizedBox(height: 12),

          //=========================== NOTA INFORMATIVA ===========================//
          // MANTENEMOS DIGNIDAD, PROTOCOLO Y RESPONSABILIDAD INSTITUCIONAL
          const Text(
            'Acceso exclusivo para personal autorizado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
