import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/donation_m.dart';
import '../../viewmodels/donation/donation_vm.dart';
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

class EditDonationDialog extends StatefulWidget {
  final Donation donation;
  final void Function(Donation) onUpdate;

  const EditDonationDialog(
      {required this.donation, required this.onUpdate, super.key});

  @override
  State<EditDonationDialog> createState() => _EditDonationDialogState();
}

class _EditDonationDialogState extends State<EditDonationDialog> {
  final _formKey      = GlobalKey<FormState>();
  final _donationsVM  = DonationsViewModel();

  late final TextEditingController _lugarCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _notaCtrl;

  @override
  void initState() {
    super.initState();
    final d   = widget.donation;
    _lugarCtrl    = TextEditingController(text: d.lugar);
    _cantidadCtrl = TextEditingController(text: d.cantidad.toString());
    _notaCtrl     = TextEditingController(text: d.nota ?? '');
  }

  @override
  void dispose() {
    _lugarCtrl.dispose();
    _cantidadCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final actualizada = Donation(
      id:        widget.donation.id,
      bookId:    widget.donation.bookId,
      titulo:    widget.donation.titulo,
      autor:     widget.donation.autor,
      cantidad:  int.tryParse(_cantidadCtrl.text) ?? widget.donation.cantidad,
      fecha:     widget.donation.fecha,
      userId:    widget.donation.userId,
      userEmail: widget.donation.userEmail,
      lugar:     _lugarCtrl.text.trim(),
      nota:      _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
    );

    try {
      await _donationsVM.updateDonation(actualizada);
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
    final d = widget.donation;

    return Form(
      key: _formKey,
      child: SidePanel(
        title:      'Editar donación',
        headerIcon: CupertinoIcons.gift_fill,
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
                  child: Row(
                    children: [
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
                            Text(d.titulo,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1C2532))),
                            const SizedBox(height: 2),
                            Text(d.autor,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Datos editables ────────────────────────────────────────────
            PanelSection(
              title: 'Datos de la donación',
              children: [
                panelField('Lugar', _lugarCtrl,
                    hint: 'Ej. Biblioteca Municipal'),
                const SizedBox(height: 12),
                panelLabeledField(
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
                      if (val == null || val <= 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                panelLabeledField(
                  label: 'Nota',
                  required: false,
                  child: TextFormField(
                    controller: _notaCtrl,
                    maxLines: 3,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF1C2532)),
                    decoration: panelInputDecoration(
                        hint: 'Observaciones adicionales (opcional)'),
                  ),
                ),
              ],
            ),

            // ── Resumen ────────────────────────────────────────────────────
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
                      const Text('Ejemplares donados',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70)),
                      Text(
                        d.cantidad.toString(),
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
void showEditDonationDialog(
  BuildContext context,
  Donation donation, {
  required void Function(Donation) onUpdate,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Editar donación',
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
          child: EditDonationDialog(donation: donation, onUpdate: onUpdate),
        ),
      );
    },
  );
}