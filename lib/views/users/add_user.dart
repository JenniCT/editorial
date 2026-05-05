import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../viewmodels/users/add_user_vm.dart';
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

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey   = GlobalKey<FormState>();
  final _viewModel = AddUserVM();

  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool      _obscurePassword = true;
  DateTime? _expiresAt;

  String? _expandedModulo;

  final Map<String, Map<String, bool>> _permisos = {
    for (final m in _kModulos)
      m: {for (final a in _kAcciones) a: false},
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Helpers permisos ─────────────────────────────────────────────────────
  bool _moduloCompleto(String m) => _permisos[m]!.values.every((v) => v);
  bool _moduloParcial(String m) {
    final vals = _permisos[m]!.values;
    return vals.any((v) => v) && !vals.every((v) => v);
  }
  int _moduloCount(String m) => _permisos[m]!.values.where((v) => v).length;

  void _toggleModulo(String m, bool value) {
    setState(() {
      for (final a in _kAcciones) {_permisos[m]![a] = value;}
    });
  }

  void _toggleAccion(String m, String a, bool value) {
    setState(() => _permisos[m]![a] = value);
  }

  void _toggleExpand(String modulo) {
    setState(() {
      _expandedModulo = _expandedModulo == modulo ? null : modulo;
    });
  }

  // ─── Fecha ────────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context:     context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate:   now,
      lastDate:    now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  // ─── Guardar ──────────────────────────────────────────────────────────────
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      uid:       DateTime.now().millisecondsSinceEpoch.toString(),
      name:      _nameController.text.trim(),
      email:     _emailController.text.trim(),
      password:  _passwordController.text.trim(),
      createAt:  DateTime.now(),
      expiresAt: _expiresAt,
      role:      Role.staff,
      status:    true,
    );

    try {
      await _viewModel.addUsuario(user, _permisos); // 👈 permisos incluidos
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SidePanel(
        title:       'Agregar nuevo usuario',
        headerIcon:  CupertinoIcons.person_badge_plus_fill,
        onSave:      _saveUser,
        saveLabel:   'Crear usuario',
        bodyBuilder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Datos ──────────────────────────────────────────────────────
            PanelSection(
              title: 'Datos del usuario',
              children: [
                panelField('Nombre completo', _nameController,
                    hint: 'Ej. Ana García López',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obligatorio'
                        : null),
                const SizedBox(height: 12),
                panelField('Correo electrónico', _emailController,
                    hint: 'usuario@ejemplo.com',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    }),
                const SizedBox(height: 12),
                panelLabeledField(
                  label: 'Contraseña',
                  child: TextFormField(
                    controller:  _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1C2532)),
                    decoration:
                        panelInputDecoration(hint: 'Mínimo 6 caracteres').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          size: 18, color: const Color(0xFF6B7280),
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Mínimo 6 caracteres'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
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
                        border: Border.all(color: const Color(0xFFEEF0F4)),
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
                              onTap: () => setState(() => _expiresAt = null),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.redAccent),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Permisos ───────────────────────────────────────────────────
            PanelSection(
              title:            'Permisos por módulo',
              showDividerAfter: false,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Activa el check del módulo para todos los permisos, '
                    'o despliégalo para elegir acciones específicas.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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

  // ─── Tile de módulo ───────────────────────────────────────────────────────
  Widget _buildModuloTile(String modulo) {
    final completo  = _moduloCompleto(modulo);
    final parcial   = _moduloParcial(modulo);
    final count     = _moduloCount(modulo);
    final expandido = _expandedModulo == modulo;

    final borderColor = completo
        ? const Color(0xFFA8D5A8)
        : parcial
            ? const Color(0xFFFFD580)
            : const Color(0xFFEEF0F4);

    final bgColor = completo
        ? const Color(0xFFEEF7EE)
        : parcial
            ? const Color(0xFFFFF8EC)
            : const Color(0xFFF8FAFC);

    final badgeColor = completo
        ? const Color(0xFF2E7D32)
        : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // ── Cabecera del módulo ──────────────────────────────────────────
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
                    child: Text(
                      modulo,
                      style: TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color: completo
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF1C2532),
                      ),
                    ),
                  ),
                  if (count > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:        badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count/${_kAcciones.length}',
                        style: const TextStyle(
                            fontSize:   10,
                            fontWeight: FontWeight.w700,
                            color:      Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    expandido
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size:  14,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),

          // ── Lista de acciones desplegable ────────────────────────────────
          if (expandido)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
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
                                bottomRight: Radius.circular(10),
                              )
                            : null,
                        border: !esUltima
                            ? const Border(
                                bottom: BorderSide(
                                    color: Color(0xFFEEEEEE), width: 0.8),
                              )
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
                          Icon(
                            _iconForAccion(accion),
                            size:  15,
                            color: activo
                                ? const Color(0xFF052B67)
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            accion,
                            style: TextStyle(
                              fontSize:   13,
                              fontWeight: activo
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: activo
                                  ? const Color(0xFF1C2532)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
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

  // ─── Icono por acción ─────────────────────────────────────────────────────
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
void showAddUserDialog(BuildContext context) {
  showGeneralDialog(
    context:            context,
    barrierDismissible: true,
    barrierLabel:       'Agregar usuario',
    barrierColor:       const Color.fromRGBO(0, 0, 0, 0.45),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder:        (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final curved = CurvedAnimation(
          parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end:   Offset.zero,
        ).animate(curved),
        child: const Align(
          alignment: Alignment.centerRight,
          child:     AddUserDialog(),
        ),
      );
    },
  );
}