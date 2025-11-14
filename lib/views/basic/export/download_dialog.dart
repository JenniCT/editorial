import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//============================================================================//
//                  DIÁLOGO DESCARGA DE REGISTROS EN EXCEL                    //
//============================================================================//
// ESTE DIÁLOGO PERMITE AL USUARIO ELEGIR ENTRE DESCARGAR TODOS LOS REGISTROS
// O SOLO LOS REGISTROS SELECCIONADOS. SU ESTILO BUSCA REFLEJAR CLARIDAD,
// SOBRIEDAD Y COHERENCIA CON UNA IDENTIDAD INSTITUCIONAL SERENA Y PROFESIONAL.

class DownloadDialog extends StatefulWidget {
  final int totalItems;
  final int selectedItems;
  final String entityName; // Ejemplo: "libros", "usuarios", "donaciones"

  const DownloadDialog({
    super.key,
    required this.totalItems,
    required this.selectedItems,
    required this.entityName,
  });

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  // VARIABLE DE ESTADO QUE CONTROLA LA OPCIÓN DE DESCARGA SELECCIONADA
  String selectedOption = 'all';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),

          //=========================== CONTENIDO PRINCIPAL ===========================//
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //=========================== ENCABEZADO SUPERIOR ===========================//
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Descargar ${widget.entityName} en Excel',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    hoverColor: const Color.fromRGBO(28, 37, 50, 0.08),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 16),

              //=========================== OPCIONES DE DESCARGA ===========================//
              _buildOption(
                title: 'Todos los ${widget.entityName}',
                subtitle: '(${widget.totalItems} en total)',
                value: 'all',
              ),
              const SizedBox(height: 8),
              _buildOption(
                title: '${widget.entityName[0].toUpperCase()}${widget.entityName.substring(1)} seleccionados',
                subtitle: widget.selectedItems > 0
                    ? '(${widget.selectedItems} seleccionados)'
                    : '',
                value: 'selected',
              ),

              const SizedBox(height: 20),

              //=========================== BOTÓN PRINCIPAL DE ACCIÓN ===========================//
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedOption);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C2532),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: const Color.fromRGBO(28, 37, 50, 0.25),
                    elevation: 4,
                  ),
                  child: Text(
                    'Descargar ${widget.entityName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //=========================== CONSTRUCCIÓN DE OPCIÓN RADIO ===========================//
  Widget _buildOption({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool isSelected = selectedOption == value;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => selectedOption = value),
      hoverColor: const Color(0xFFF2F4F7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE9EBEF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C2532) : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1C2532) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1C2532),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: title),
                    if (subtitle.isNotEmpty)
                      TextSpan(
                        text: ' $subtitle',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Función auxiliar para mostrar el diálogo y devolver la opción elegida
Future<String?> mostrarDialogoDescarga(
  BuildContext context, {
  required int totalItems,
  required int selectedItems,
  required String entityName,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => DownloadDialog(
      totalItems: totalItems,
      selectedItems: selectedItems,
      entityName: entityName,
    ),
  );
}
