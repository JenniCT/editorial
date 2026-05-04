import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/sale_m.dart';
import '../../viewmodels/market/sales_vm.dart';
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

class EditSaleDialog extends StatefulWidget {
  final Sale sale;
  final void Function(Sale) onUpdate;

  const EditSaleDialog({required this.sale, required this.onUpdate, super.key});

  @override
  State<EditSaleDialog> createState() => _EditSaleDialogState();
}

class _EditSaleDialogState extends State<EditSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _salesVM = SalesViewModel();

  late final TextEditingController _lugarCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _precioCtrl;

  double get _totalCalculado {
    final cant   = int.tryParse(_cantidadCtrl.text)  ?? 0;
    final precio = double.tryParse(_precioCtrl.text) ?? 0.0;
    return cant * precio;
  }

  @override
  void initState() {
    super.initState();
    final s     = widget.sale;
    _lugarCtrl    = TextEditingController(text: s.lugar);
    _cantidadCtrl = TextEditingController(text: s.cantidad.toString());
    _precioCtrl   = TextEditingController(
        text: s.precioUnitario.toStringAsFixed(2));

    _cantidadCtrl.addListener(() => setState(() {}));
    _precioCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cantidadCtrl.removeListener(() => setState(() {}));
    _precioCtrl.removeListener(() => setState(() {}));
    _lugarCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final actualizada = widget.sale.copyWith(
      lugar:          _lugarCtrl.text.trim(),
      cantidad:       int.tryParse(_cantidadCtrl.text)  ?? widget.sale.cantidad,
      precioUnitario: double.tryParse(_precioCtrl.text) ?? widget.sale.precioUnitario,
      total:          _totalCalculado,
    );

    try {
      await _salesVM.updateSale(actualizada);
      widget.onUpdate(actualizada);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sale;

    return Form(
      key: _formKey,
      child: SidePanel(
        title:      'Editar venta',
        headerIcon: CupertinoIcons.cart_fill,
        onSave:     _guardar,
        saveLabel:  'Guardar cambios',
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Libro (solo lectura) ───────────────────────────────────────
            PanelSection(
              title: 'Libro',
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEF0F4)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF052B67).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(CupertinoIcons.book_fill,
                          size: 18, color: Color(0xFF052B67)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.titulo,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C2532))),
                          const SizedBox(height: 2),
                          Text(s.autor,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),

            // ── Datos editables ────────────────────────────────────────────
            PanelSection(
              title: 'Datos de la venta',
              children: [
                panelField('Lugar', _lugarCtrl, hint: 'Ej. Feria del libro'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: panelLabeledField(
                        label: 'Cantidad',
                        child: TextFormField(
                          controller: _cantidadCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF1C2532)),
                          decoration: panelInputDecoration(),
                          validator: (v) {
                            final val = int.tryParse(v ?? '');
                            if (val == null || val <= 0) return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: panelLabeledField(
                        label: 'Precio unitario (\$)',
                        child: TextFormField(
                          controller: _precioCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'))
                          ],
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF1C2532)),
                          decoration: panelInputDecoration(hint: '0.00'),
                          validator: (v) {
                            final val = double.tryParse(v ?? '');
                            if (val == null || val < 0) return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Resumen reactivo ───────────────────────────────────────────
            PanelSection(
              title: 'Resumen',
              showDividerAfter: false,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF052B67),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total de la venta',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70)),
                      Text(
                        '\$${_totalCalculado.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ─── Función de apertura ──────────────────────────────────────────────────────
void showEditSaleDialog(
  BuildContext context,
  Sale sale, {
  required void Function(Sale) onUpdate,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Editar venta',
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: Align(
          alignment: Alignment.centerRight,
          child: EditSaleDialog(sale: sale, onUpdate: onUpdate),
        ),
      );
    },
  );
}

