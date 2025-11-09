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
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

//=========================== ESTADO DEL LOGIN ===========================//
// ADMINISTRA CONTROLADORES, ANIMACIONES Y CICLO DE VIDA DEL WIDGET
class _LoginState extends State<Login> with SingleTickerProviderStateMixin {

  // CONTROLADOR DE LA LOGICA DEL LOGIN
  final LoginVM vm = LoginVM();

  // CONTROLADOR DE ANIMACION PARA LA MASCOTA
  late AnimationController mascotController;

  @override
  void initState() {
    super.initState();

    //=========================== INICIALIZACION DE ANIMACION ===========================//
    // ANIMACION DE MOVIMIENTO SUAVE PARA DAR PRESENCIA HUMANA A LA MASCOTA
    // ANIMACION DE DOS SEGUNDOS QUE SUBE Y BAJA PARA GENERAR CALIDEZ EMOCIONAL
    mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
    // REPETICION EN REVERSE PARA UN CICLO CONTINUO Y SERENO
    ..repeat(reverse: true);
  }

  @override
  void dispose() {
    //=========================== LIMPIEZA DE CONTROLADORES ===========================//
    // LIBERACION DE RECURSOS PARA EVITAR FUGAS Y MANTENER SOLIDEZ TECNICA
    mascotController.dispose();
    vm.emailController.dispose();
    vm.passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //=========================== ESTRUCTURA VISUAL PRINCIPAL ===========================//
    // SE USA UN DEGRADADO SUAVE PARA CONSTRUIR UN AMBIENTE ACOGEDOR Y PROFESIONAL
    // TONOS AZULES-GRISES QUE REFUERZAN ESTABILIDAD INSTITUCIONAL
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDDE3EA), // TONO SUPERIOR SUAVE PARA DAR LIGEREZA
              Color(0xFFC9D3E0), // TONO INFERIOR QUE APORTA PROFUNDIDAD
            ],
          ),
        ),

        //=========================== SISTEMA RESPONSIVE ===========================//
        // SE ADAPTA A PANTALLAS AMPLIAS Y MOVILES PARA UNA EXPERIENCIA FLUIDA
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 700;
            final desktop = constraints.maxWidth >= 1000;

            return Center(
              child: SingleChildScrollView(

                // CONTENEDOR CENTRAL CON ANCHO MAXIMO CONTROLADO
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 40,
                    ),

                    //=========================== DISTRIBUCION SEGUN DISPOSITIVO ===========================//
                    // VERSION MOVIL: COLUMNA VERTICAL QUE PRIORIZA LEGIBILIDAD
                    child: mobile
                        ? Column(
                            children: [

                              // MASCOTA ANIMADA COMO ELEMENTO DE ACOMPANIAMIENTO HUMANO
                              LoginMascot(controller: mascotController),

                              const SizedBox(height: 24),

                              // TARJETA DE LOGIN COMPACTA PARA MOVILES
                              LoginCard(vm: vm, desktop: false),
                            ],
                          )

                        // VERSION ESCRITORIO: DISTRIBUCION HORIZONTAL EQUILIBRADA
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              //=========================== TARJETA DE FORMULARIO ===========================//
                              // EN ESCRITORIO SE ALINEA A LA DERECHA PARA DAR JERARQUIA VISUAL
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: LoginCard(vm: vm, desktop: desktop),
                                ),
                              ),

                              const SizedBox(width: 60),

                              //=========================== MASCOTA DE APOYO EMOCIONAL ===========================//
                              // UBICADA A LA DERECHA PARA EQUILIBRAR LA COMPOSICION
                              LoginMascot(controller: mascotController),
                            ],
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
