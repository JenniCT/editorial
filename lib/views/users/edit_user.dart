import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../viewmodels/users/add_user_vm.dart';
import '../../widgets/global/dialog.dart';
import '../../widgets/side_panel/side_panel.dart';
import '../../widgets/side_panel/side_panel_fields.dart';
import '../../widgets/side_panel/side_panel_section.dart';

const List<String> _kModulos = [
  'Inventario', 'Acervo', 'Ventas', 'Donaciones', 'Usuarios',
];

const List<String> _kAcciones = [
  'Ver', 'Agregar', 'Editar', 'Eliminar',
  'Importar', 'Exportar', 'QR', 'Historial',
];

class EditUserDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onUpdated;
  const EditUserDialog({required this.user, this.onUpdated, super.key});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey   = GlobalKey<FormState>();
  final _viewModel = AddUserVM();

  late final TextEditingController _nameController;

  bool      _status     = true;
  DateTime? _expiresAt;
  String?   _expandedModulo;
  bool      _loadingPermisos = true;

  Map<String, Map<String, bool>> _permisos = {
    for (final m in _kModulos)
      m: {for (final a in _kAcciones) a: false},
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _status         = widget.user.status;
    _expiresAt      = widget.user.expiresAt;
    _cargarPermisos();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _cargarPermisos() async {
    try {
      final perms = await _viewModel.getPermisos(widget.user.uid!);
      setState(() {
        _permisos        = perms;
        _loadingPermisos = false;
      });
    } catch (_) {
      setState(() => _loadingPermisos = false);
    }
  }

  // ─── Helpers permisos ─────────────────────────────────────────────────────
  bool _moduloCompleto(String m) => _permisos[m]!.values.every((v) => v);
  bool _moduloParcial(String m) {
    final vals = _permisos[m]!.values;
    return vals.any((v) => v) && !vals.every((v) => v);
  }
  int _moduloCount(String m) => _permisos[m]!.values.where((v) => v).length;

  void _toggleModulo(String m, bool value) =>
      setState(() { for (final a in _kAcciones){ _permisos[m]![a] = value;} });

  void _toggleAccion(String m, String a, bool value) =>
      setState(() => _permisos[m]![a] = value);

  void _toggleExpand(String modulo) => setState(() =>
      _expandedModulo = _expandedModulo == modulo ? null : modulo);

  // ─── Fecha ────────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context:     context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 30)),
      firstDate:   now,
      lastDate:    now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) throw Exception('_validation');

    final updated = widget.user.copyWith(
      name:      _nameController.text.trim(),
      status:    _status,
      expiresAt: _expiresAt,
      updatedAt: DateTime.now(),
    );

    try {
      await _viewModel.updateUsuario(updated, _permisos);
    } catch (e) {
      if (mounted) {
        showCustomToast(context,
            title:   'Error',
            message: 'No se pudo actualizar el usuario.',
            color:   Colors.redAccent,
            icon:    CupertinoIcons.xmark_circle_fill,
            durationSeconds: 3);
      }
      rethrow;
    }

    widget.onUpdated?.call();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!dialogContext.mounted) return;

          Navigator.of(dialogContext).pop();
          Navigator.of(dialogContext, rootNavigator: true).pop();
        });

        return CustomToast(
          title: 'Usuario actualizado',
          message: '${updated.name} fue actualizado correctamente.',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        );
      }
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title:       'Editar usuario',
        headerIcon:  CupertinoIcons.person_fill,
        onSave:      _saveUser,
        saveLabel:   'Guardar cambios',
        bodyBuilder: (_) => _loadingPermisos
            ? const Padding(
                padding: EdgeInsets.all(40),
                child:   Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Datos ────────────────────────────────────────────────
                  PanelSection(
                    title: 'Datos del usuario',
                    children: [
                      panelField('Nombre completo', _nameController,
                          hint: 'Ej. Ana García López',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo obligatorio'
                              : null),
                      const SizedBox(height: 12),

                      // Email — solo lectura
                      panelLabeledField(
                        label: 'Correo electrónico',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color:        const Color(0xFFF1F5FB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEEF0F4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.mail,
                                  size: 15, color: Color(0xFF6B7280)),
                              const SizedBox(width: 8),
                              Text(widget.user.email,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Fecha expiración
                      panelLabeledField(
                        label:    'Fecha de expiración',
                        required: false,
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color:        const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFEEF0F4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.calendar,
                                    size: 16, color: Color(0xFF6B7280)),
                                const SizedBox(width: 8),
                                Text(
                                  _expiresAt != null
                                      ? '${_expiresAt!.day.toString().padLeft(2, '0')}/'
                                          '${_expiresAt!.month.toString().padLeft(2, '0')}/'
                                          '${_expiresAt!.year}'
                                      : 'Sin fecha de expiración',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _expiresAt != null
                                        ? const Color(0xFF1C2532)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                const Spacer(),
                                if (_expiresAt != null)
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _expiresAt = null),
                                    child: const Icon(Icons.close,
                                        size: 16, color: Colors.redAccent),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Estado activo/inactivo
                      panelLabeledField(
                        label:    'Estado',
                        required: false,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEEF0F4)),
                          ),
                          child: Row(children: [
                            _statusBtn('Activo',   true),
                            Container(width: 1, height: 38, color: const Color(0xFFEEF0F4)),
                            _statusBtn('Inactivo', false),
                          ]),
                        ),
                      ),
                    ],
                  ),

                  // ── Permisos ──────────────────────────────────────────────
                  PanelSection(
                    title:            'Permisos por módulo',
                    showDividerAfter: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Activa el check del módulo para todos los permisos, '
                          'o despliégalo para elegir acciones específicas.',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ),
                      ..._kModulos.map(_buildModuloTile),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _statusBtn(String label, bool value) {
    final selected = _status == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: selected
                ? (value ? const Color(0xFF2E7D32) : Colors.redAccent)
                : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left:  value  ? const Radius.circular(7) : Radius.zero,
              right: !value ? const Radius.circular(7) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF6B7280))),
        ),
      ),
    );
  }

  // ─── Tile de módulo (idéntico a AddUserDialog) ────────────────────────────
  Widget _buildModuloTile(String modulo) {
    final completo  = _moduloCompleto(modulo);
    final parcial   = _moduloParcial(modulo);
    final count     = _moduloCount(modulo);
    final expandido = _expandedModulo == modulo;

    final borderColor = completo
        ? const Color(0xFFA8D5A8)
        : parcial ? const Color(0xFFFFD580) : const Color(0xFFEEF0F4);
    final bgColor = completo
        ? const Color(0xFFEEF7EE)
        : parcial ? const Color(0xFFFFF8EC) : const Color(0xFFF8FAFC);
    final badgeColor =
        completo ? const Color(0xFF2E7D32) : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _toggleExpand(modulo),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: Checkbox(
                      value: completo ? true : (parcial ? null : false),
                      tristate:    true,
                      activeColor: const Color(0xFF052B67),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      onChanged: (v) => _toggleModulo(modulo, v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(modulo,
                        style: TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w600,
                          color: completo
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF1C2532),
                        )),
                  ),
                  if (count > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color:        badgeColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('$count/${_kAcciones.length}',
                          style: const TextStyle(
                              fontSize:   10,
                              fontWeight: FontWeight.w700,
                              color:      Colors.white)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    expandido
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size: 14, color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          if (expandido)
            Container(
              decoration:
                  BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
              child: Column(
                children: _kAcciones.map((accion) {
                  final activo   = _permisos[modulo]![accion]!;
                  final esUltima = accion == _kAcciones.last;
                  return InkWell(
                    onTap: () => _toggleAccion(modulo, accion, !activo),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: activo
                            ? const Color(0xFF052B67).withValues(alpha: 0.04)
                            : Colors.transparent,
                        borderRadius: esUltima
                            ? const BorderRadius.only(
                                bottomLeft:  Radius.circular(10),
                                bottomRight: Radius.circular(10))
                            : null,
                        border: !esUltima
                            ? const Border(
                                bottom: BorderSide(
                                    color: Color(0xFFEEEEEE), width: 0.8))
                            : null,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 20, height: 20,
                            child: Checkbox(
                              value:       activo,
                              activeColor: const Color(0xFF052B67),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              onChanged: (v) =>
                                  _toggleAccion(modulo, accion, v ?? false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(_iconForAccion(accion),
                              size:  15,
                              color: activo
                                  ? const Color(0xFF052B67)
                                  : const Color(0xFF9CA3AF)),
                          const SizedBox(width: 8),
                          Text(accion,
                              style: TextStyle(
                                fontSize:   13,
                                fontWeight: activo
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: activo
                                    ? const Color(0xFF1C2532)
                                    : const Color(0xFF6B7280),
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForAccion(String accion) {
    switch (accion) {
      case 'Ver':       return CupertinoIcons.eye;
      case 'Agregar':   return CupertinoIcons.add_circled;
      case 'Editar':    return CupertinoIcons.pencil;
      case 'Eliminar':  return CupertinoIcons.trash;
      case 'Importar':  return CupertinoIcons.arrow_up_circle;
      case 'Exportar':  return CupertinoIcons.arrow_down_circle;
      case 'QR':        return CupertinoIcons.qrcode;
      case 'Historial': return CupertinoIcons.clock;
      default:          return CupertinoIcons.circle;
    }
  }
}

// ─── Función de apertura ──────────────────────────────────────────────────────
void showEditUserDialog(BuildContext context, UserModel user,
    {VoidCallback? onUpdated}) {
  showGeneralDialog(
    context:            context,
    barrierDismissible: true,
    barrierLabel:       'Editar usuario',
    barrierColor:       const Color.fromRGBO(0, 0, 0, 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder:        (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end:   Offset.zero,
        ).animate(curved),
        child: Align(
          alignment: Alignment.centerRight,
          child: EditUserDialog(user: user, onUpdated: onUpdated),
        ),
      );
    },
  );
}