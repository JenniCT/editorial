import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../models/sale_m.dart';
import '../../viewmodels/market/sales_vm.dart';
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

// ================================================================
//  FUNCIÓN HELPER
// ================================================================
void mostrarDetallVenta(
  BuildContext context,
  Sale sale, {
  required void Function(Sale) onUpdate,
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
          child: _DetalleVentaPanel(sale: sale, onUpdate: onUpdate),
        ),
      );
    },
  );
}

// ================================================================
//  PANEL LATERAL
// ================================================================
class _DetalleVentaPanel extends StatefulWidget {
  final Sale sale;
  final void Function(Sale) onUpdate;

  const _DetalleVentaPanel({required this.sale, required this.onUpdate});

  @override
  State<_DetalleVentaPanel> createState() => _DetalleVentaPanelState();
}

class _DetalleVentaPanelState extends State<_DetalleVentaPanel> {
  late Sale sale;
  bool _editando = false;

  late final TextEditingController _lugarCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _precioCtrl;

  final _formKey = GlobalKey<FormState>();
  final _salesVM = SalesViewModel();

  // Total calculado en tiempo real
  double get _totalCalculado {
    final cant   = int.tryParse(_cantidadCtrl.text)    ?? 0;
    final precio = double.tryParse(_precioCtrl.text)   ?? 0.0;
    return cant * precio;
  }

  @override
  void initState() {
    super.initState();
    sale = widget.sale;
    _lugarCtrl    = TextEditingController(text: sale.lugar);
    _cantidadCtrl = TextEditingController(text: sale.cantidad.toString());
    _precioCtrl   = TextEditingController(text: sale.precioUnitario.toStringAsFixed(2));

    // Recalcular total en tiempo real
    _cantidadCtrl.addListener(() => setState(() {}));
    _precioCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _lugarCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final actualizada = sale.copyWith(
      lugar:          _lugarCtrl.text.trim(),
      cantidad:       int.tryParse(_cantidadCtrl.text)  ?? sale.cantidad,
      precioUnitario: double.tryParse(_precioCtrl.text) ?? sale.precioUnitario,
      total:          _totalCalculado,
    );

    try {
      await _salesVM.updateSale(actualizada);
      setState(() {
        sale      = actualizada;
        _editando = false;
      });
      widget.onUpdate(actualizada);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title:      _editando ? 'Editar venta' : 'Detalle de venta',
        headerIcon: CupertinoIcons.cart_fill,
        saveLabel:  _editando ? 'Guardar cambios' : 'Editar',
        onSave: _editando
            ? _guardarCambios
            : () => setState(() => _editando = true),
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Libro ──────────────────────────────────────────────────────
            PanelSection(
              title: 'Libro',
              children: [
                _infoCard(
                  icon: CupertinoIcons.book_fill,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sale.titulo,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C2532))),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 13, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(sale.autor,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280))),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            // ── Datos ──────────────────────────────────────────────────────
            PanelSection(
              title: 'Datos de la venta',
              children: [
                if (_editando) ...[
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
                ] else ...[
                  _infoRow('Lugar',           sale.lugar),
                  _infoRow('Cantidad',        sale.cantidad.toString()),
                  _infoRow('Precio unitario', '\$${sale.precioUnitario.toStringAsFixed(2)}'),
                  _infoRow('Total',           '\$${sale.total.toStringAsFixed(2)}'),
                  _infoRow('Fecha',           _formatFecha(sale.fecha)),
                  _infoRow('Hora',            _formatHora(sale.fecha)),
                ],
              ],
            ),

            // ── Resumen ────────────────────────────────────────────────────
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
                      const Text('Total de la venta',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70)),
                      Text(
                        // En edición muestra el total calculado en vivo
                        '\$${(_editando ? _totalCalculado : sale.total).toStringAsFixed(2)}',
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
            if (!_editando)
              PanelSection(
                title: 'Bitácora',
                showDividerAfter: false,
                children: [
                  _buildBitacoraItem(
                    titulo:       'Registrado',
                    fecha:        _formatFecha(sale.fecha),
                    hora:         _formatHora(sale.fecha),
                    usuario:      sale.userEmail,
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

  // ── Helpers (sin cambios) ─────────────────────────────────────────────────
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
            width: 110,
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

  String _formatFecha(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _formatHora(DateTime dt) {
    final h  = dt.hour;
    final m  = dt.minute.toString().padLeft(2, '0');
    final p  = h >= 12 ? 'p.m.' : 'a.m.';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $p';
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
            child: Column(children: [
              Container(
                width: 12, height: 12,
                decoration: const BoxDecoration(
                    color: Color(0xFF052B67), shape: BoxShape.circle)),
              if (!isLast)
                Expanded(
                  child: Center(
                    child: Container(
                        width: 2, color: const Color(0xFFDDE3EE)),
                  ),
                ),
            ]),
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