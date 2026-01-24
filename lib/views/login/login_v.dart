//=========================== IMPORTACIONES PRINCIPALES ===========================//
// ESTAS IMPORTACIONES REUNEN LOS BLOQUES FUNDAMENTALES QUE SOSTIENEN LA VISTA DE LOGIN
// SE MANTIENEN ORDENADAS PARA REFLEJAR CLARIDAD TECNICA Y COHERENCIA INSTITUCIONAL

//=========================== FLUTTER: BASE DEL SISTEMA DE UI ===========================//
// PROPORCIONA WIDGETS, ESTILOS Y MECANISMOS DE RENDERIZADO
import 'package:flutter/material.dart';

//=========================== VISTA-MODELO DEL LOGIN ===========================//
// GESTIONA ESTADOS, VALIDACIONES Y FLUJO LOGICO DEL PROCESO DE AUTENTICACION
import '../../viewmodels/login/login_vm.dart';

//=========================== WIDGET DE MASCOTA ANIMADA ===========================//
// ELEMENTO SIMBOLICO QUE ACOMPAÑA AL USUARIO Y HUMANIZA LA EXPERIENCIA
import '../../widgets/login/mascot.dart';

//=========================== TARJETA DE FORMULARIO DE LOGIN ===========================//
// CONTIENE CAMPOS, INTERACCIONES Y ESTRUCTURA VISUAL DEL ACCESO
import '../../widgets/login/card.dart';


//=========================== WIDGET PRINCIPAL DE LOGIN ===========================//
// ESTE WIDGET ACTUA COMO PUERTA DE INGRESO Y PRESENTA UNA EXPERIENCIA VISUAL CUIDADA
//=========================== WIDGET PRINCIPAL DE LOGIN ===========================//
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  // 1. Declaramos el VM pero NO lo inicializamos aquí para respetar el ciclo de vida
  late final LoginVM vm;
  late AnimationController mascotController;

  @override
  void initState() {
    super.initState();
    
    // 2. Inicialización correcta: Solo ocurre una vez al crear el estado
    vm = LoginVM();

    mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // 3. Limpieza profunda: Evita fugas de memoria en Web
    mascotController.dispose();
    // Importante: No llamamos a vm.dispose aquí si el VM no tiene ese método,
    // pero sí a sus controladores si los tiene públicos.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si el teclado está abierto (en móvil) midiendo los 'viewInsets'
    // Si es mayor a 0, el teclado está ocupando espacio y ocultamos la mascota.
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDDE3EA), Color(0xFFC9D3E0)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 700;
            final desktop = constraints.maxWidth >= 1000;

            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    // 4. AutofillGroup: Envuelve todo el formulario para que el navegador 
                    // entienda que el correo y la contraseña están relacionados.
                    child: AutofillGroup( 
                      child: mobile
                          ? Column(
                              children: [
                                // Ocultamos la mascota si el teclado está abierto
                                if (!isKeyboardVisible) 
                                  LoginMascot(controller: mascotController),
                                
                                const SizedBox(height: 24),
                                LoginCard(vm: vm, desktop: false),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: LoginCard(vm: vm, desktop: desktop),
                                  ),
                                ),
                                const SizedBox(width: 60),
                                LoginMascot(controller: mascotController),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}