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
    return Scaffold(
      // ESTO ES CLAVE: Evita que el teclado deforme el layout y cause el cuadro blanco
      resizeToAvoidBottomInset: false, 
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
            final bool isMobile = constraints.maxWidth < 700;
            final bool isDesktop = constraints.maxWidth >= 1000;

            return Center(
              child: SingleChildScrollView(
                // Permitimos scroll solo si es necesario para alcanzar los botones
                physics: const BouncingScrollPhysics(), 
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    child: AutofillGroup( 
                      child: isMobile
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 1. ELIMINAMOS LA MASCOTA EN MÓVIL PERMANENTEMENTE
                                // Esto libera espacio para que el teclado no tape el LoginCard
                                LoginCard(vm: vm, desktop: false),
                                
                                // 2. Colchón de espacio dinámico para el teclado
                                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: LoginCard(vm: vm, desktop: isDesktop),
                                  ),
                                ),
                                const SizedBox(width: 60),
                                // En escritorio la mascota se mantiene siempre
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