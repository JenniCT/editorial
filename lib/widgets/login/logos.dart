//=========================== IDENTIDAD VISUAL INSTITUCIONAL ===========================//
// ESTE WIDGET PRESENTA LOS LOGOS OFICIALES QUE DAN CONTEXTUALIZACION, AUTORIDAD
// Y PROXIMIDAD INSTITUCIONAL. LA DISPOSICION EQUILIBRADA REFUERZA LEGITIMIDAD Y
// UNA NARRATIVA DE UNION ENTRE SISTEMAS Y ENTIDADES.

import 'package:flutter/material.dart';

class LoginLogos extends StatelessWidget {
  const LoginLogos({super.key});

  @override
  Widget build(BuildContext context) {

    //=========================== FILA DE LOGOS ===========================//
    // ALINEADOS AL CENTRO PARA EXPRESAR EQUILIBRIO, ESTABILIDAD Y COMPROMISO
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        //=========================== LOGO PRINCIPAL UNACH ===========================//
        // REPRESENTA SOLIDEZ ACADEMICA Y DECLARA EL ENTORNO INSTITUCIONAL
        Image.asset(
          'assets/images/unach.png',
          height: 45,
        ),

        const SizedBox(width: 24), // ESPACIO RESPIRABLE ENTRE IDENTIDADES

        //=========================== LOGO SISTEMA SIRESU ===========================//
        // MARCA EL VINCULO ENTRE LA INSTITUCION Y EL SISTEMA QUE SE UTILIZA
        Image.asset(
          'assets/images/siresu.png',
          height: 45,
        ),
      ],
    );
  }
}
