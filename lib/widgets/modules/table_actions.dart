import 'package:flutter/material.dart';
import '../buttons/action_icon_btn.dart';

class TableActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onQr;
  final VoidCallback? onHistory;
  final VoidCallback? onCost;
  final VoidCallback? onDelete;

  final bool showQR;
  final bool showCost;

  const TableActions({
    super.key,
    this.onEdit,
    this.onQr,
    this.onHistory,
    this.onCost,
    this.onDelete,
    this.showQR = false,
    this.showCost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //=========================== EDITAR ===========================//
        ActionIconButton(
          icon: Icons.edit_outlined,
          color: const Color(0xFF052B67),
          tooltip: 'Editar',
          onPressed: onEdit ?? () {},
        ),

        //=========================== QR ===========================//
        if(showQR)
          ActionIconButton(
            icon: Icons.qr_code_2_outlined,
            color: const Color(0xFF052B67),
            tooltip: 'Generar QR',
            onPressed: onQr ?? () {},
          ),

        //=========================== HISTORIAL ===========================//
        ActionIconButton(
          icon: Icons.history,
          color: const Color(0xFF052B67),
          tooltip: 'Historial',
          onPressed: onHistory ?? () {},
        ),

        //=========================== COSTO ===========================//
        if (showCost)
          ActionIconButton(
            icon: Icons.attach_money,
            color: const Color(0xFF052B67),
            tooltip: 'Costo de producción',
            onPressed: onCost ?? () {},
          ),

        //=========================== DAR DE BAJA ===========================//
        ActionIconButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          tooltip: 'Dar de baja',
          onPressed: onDelete ?? () {},
        ),
      ],
    );
  }
}