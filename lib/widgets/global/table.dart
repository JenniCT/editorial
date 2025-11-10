import 'package:flutter/material.dart';

//=========================== WIDGET CUSTOM TABLE ===========================//
// TABLA PERSONALIZADA PARA INVENTARIO DE LIBROS
// PERMITE MOSTRAR CABECERAS, FILAS, ANCHO ADAPTATIVO, ESTILO DE HEADER Y WIDGET SUPERIOR
class CustomTable extends StatelessWidget {
  final List<Widget> headers; // LISTA DE CABECERAS DE COLUMNA
  final List<List<Widget>> rows; // FILAS DE LA TABLA
  final double rowHeight; // ALTURA DE CADA FILA
  final double? width; // ANCHO TOTAL OPCIONAL
  final List<double>? columnWidths; // ANCHO PERSONALIZADO DE CADA COLUMNA
  final TextStyle headerStyle; // ESTILO DE TEXTO DEL HEADER
  final Widget? topWidget; // WIDGET OPCIONAL POR ENCIMA DE LA TABLA (BÚSQUEDA, BOTONES, ETC.)

  const CustomTable({
    required this.headers,
    required this.rows,
    this.rowHeight = 50,
    this.width,
    this.columnWidths,
    this.headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.topWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = width ?? 1000; // ANCHO TOTAL POR DEFECTO SI NO SE ESPECIFICA
    final calculatedColumnWidths = columnWidths ??
        List.generate(headers.length, (index) => totalWidth / headers.length);

    //=========================== MÉTODO PARA CREAR UNA FILA ===========================//
    // CONSTRUYE FILA DE HEADER O DATOS
    Widget buildRow(List<Widget> children, {bool isHeader = false}) {
      return SizedBox(
        height: rowHeight,
        child: Row(
          children: List.generate(children.length, (index) {
            return Container(
              width: calculatedColumnWidths[index],
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerLeft,
              child: children[index],
            );
          }),
        ),
      );
    }

    //=========================== FILA VACÍA ===========================//
    // MOSTRAR MENSAJE AMIGABLE CUANDO NO HAY DATOS DISPONIBLES
    Widget buildEmptyRow() {
      return SizedBox(
        height: rowHeight,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "No hay libros disponibles",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    //=========================== CONTENEDOR PRINCIPAL ===========================//
    // BORDES REDONDEADOS, FONDO SEMI-TRANSPARENTE, SCROLL HORIZONTAL Y VERTICAL
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // BORDES REDONDEADOS PARA ESTILO SUAVE
      child: Container(
        padding: const EdgeInsets.all(16), // PADDING INTERNO PARA RESPIRACIÓN VISUAL
        color: const Color.fromRGBO(28, 37, 50, 0.7), // FONDO OSCURO SEMI-TRANSPARENTE
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //=========================== WIDGET SUPERIOR ===========================//
                  // PUEDE SER BARRA DE BÚSQUEDA, BOTONES O FILTROS
                  if (topWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: topWidget!,
                    ),

                  //=========================== HEADER ===========================//
                  buildRow(headers, isHeader: true),
                  const Divider(color: Colors.white54), // DIVISOR SUTIL ENTRE HEADER Y FILAS

                  //=========================== FILAS DE DATOS ===========================//
                  // SI NO HAY FILAS, MOSTRAR MENSAJE VACÍO
                  if (rows.isEmpty)
                    buildEmptyRow()
                  else
                    ...rows.map(
                      (columns) => Column(
                        children: [
                          buildRow(columns),
                          const Divider(color: Colors.white30), // DIVISOR ENTRE FILAS
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
