import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../models/donation_m.dart';
import '../../viewmodels/donation/donation_vm.dart';
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

// ================================================================
//  FUNCIÓN HELPER
// ================================================================
void mostrarDetalleDonacion(
  BuildContext context,
  Donation donation, {
  required void Function(Donation) onUpdate,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar detalle',
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: Align(
          alignment: Alignment.centerRight,
          child: _DetalleDonacionPanel(
              donation: donation, onUpdate: onUpdate),
        ),
      );
    },
  );
}

// ================================================================
//  PANEL LATERAL
// ================================================================
class _DetalleDonacionPanel extends StatefulWidget {
  final Donation donation;
  final void Function(Donation) onUpdate;

  const _DetalleDonacionPanel(
      {required this.donation, required this.onUpdate});

  @override
  State<_DetalleDonacionPanel> createState() => _DetalleDonacionPanelState();
}

class _DetalleDonacionPanelState extends State<_DetalleDonacionPanel> {
  late Donation donation;
  bool _editando = false;

  late final TextEditingController _lugarCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _notaCtrl;

  final _formKey     = GlobalKey<FormState>();
  final _donationsVM = DonationsViewModel();

  @override
  void initState() {
    super.initState();
    donation      = widget.donation;
    _lugarCtrl    = TextEditingController(text: donation.lugar);
    _cantidadCtrl = TextEditingController(text: donation.cantidad.toString());
    _notaCtrl     = TextEditingController(text: donation.nota ?? '');
  }

  @override
  void dispose() {
    _lugarCtrl.dispose();
    _cantidadCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  String _formatFecha(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _formatHora(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final periodo = h >= 12 ? 'p.m.' : 'a.m.';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $periodo';
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final actualizada = Donation(
      id:        donation.id,
      bookId:    donation.bookId,
      titulo:    donation.titulo,
      autor:     donation.autor,
      cantidad:  int.tryParse(_cantidadCtrl.text) ?? donation.cantidad,
      fecha:     donation.fecha,
      userId:    donation.userId,
      userEmail: donation.userEmail,
      lugar:     _lugarCtrl.text.trim(),
      nota:      _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
    );

    try {
      await _donationsVM.updateDonation(actualizada);
      setState(() {
        donation  = actualizada;
        _editando = false;
      });
      widget.onUpdate(actualizada);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title:      _editando ? 'Editar donación' : 'Detalle de donación',
        headerIcon: CupertinoIcons.gift_fill,
        saveLabel:  _editando ? 'Guardar cambios' : 'Editar',
        onSave: _editando
            ? _guardarCambios
            : () => setState(() => _editando = true),
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Libro ─────────────────────────────────────────────────────
            PanelSection(
              title: 'Libro',
              children: [
                _infoCard(
                  icon: CupertinoIcons.book_fill,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.titulo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C2532),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 13, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              donation.autor,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Datos de la donación ───────────────────────────────────────
            PanelSection(
              title: 'Datos de la donación',
              children: [
                if (_editando) ...[
                  panelField(
                    'Lugar',
                    _lugarCtrl,
                    hint: 'Ej. Biblioteca Municipal',
                  ),
                  const SizedBox(height: 12),
                  panelField(
                    'Cantidad',
                    _cantidadCtrl,
                    hint: '1',
                    onlyDigits: true,
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val == null || val <= 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  panelLabeledField(
                    label:    'Nota',
                    required: false,
                    child: TextFormField(
                      controller: _notaCtrl,
                      maxLines:   3,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1C2532)),
                      decoration: panelInputDecoration(
                          hint: 'Observaciones adicionales (opcional)'),
                    ),
                  ),
                ] else ...[
                  _infoRow('Lugar',    donation.lugar),
                  _infoRow('Cantidad', donation.cantidad.toString()),
                  _infoRow('Fecha',    _formatFecha(donation.fecha)),
                  _infoRow('Hora',     _formatHora(donation.fecha)),
                  if (donation.nota != null && donation.nota!.isNotEmpty)
                    _infoRow('Nota', donation.nota!),
                ],
              ],
            ),

            // ── Resumen ────────────────────────────────────────────────────
            if (!_editando)
              PanelSection(
                title: 'Resumen',
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
                        const Text(
                          'Ejemplares donados',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70),
                        ),
                        Text(
                          '${donation.cantidad}',
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

            // ── Bitácora ───────────────────────────────────────────────────
            PanelSection(
              title: 'Bitácora',
              showDividerAfter: false,
              children: [
                _buildBitacoraItem(
                  titulo:       'Registrado',
                  fecha:        _formatFecha(donation.fecha),
                  hora:         _formatHora(donation.fecha),
                  usuario:      donation.userEmail,
                  labelUsuario: 'Registrado por',
                  isLast:       true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers visuales ──────────────────────────────────────────────────────
  Widget _infoCard({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF052B67).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF052B67)),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C2532))),
          ),
        ],
      ),
    );
  }

  Widget _buildBitacoraItem({
    required String titulo,
    required String fecha,
    required String hora,
    required String usuario,
    required String labelUsuario,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF052B67),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                          width: 2, color: const Color(0xFFDDE3EE)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEF0F4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C2532))),
                    const SizedBox(height: 10),
                    _bitacoraRow('Fecha:',         fecha),
                    const SizedBox(height: 5),
                    _bitacoraRow('Hora:',          hora),
                    const SizedBox(height: 5),
                    _bitacoraRow('$labelUsuario:', usuario),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bitacoraRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 105,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280))),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C2532))),
        ),
      ],
    );
  }
}