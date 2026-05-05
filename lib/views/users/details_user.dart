import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user.dart';
import '../../viewmodels/users/add_user_vm.dart';
import '../../widgets/side_panel/side_panel_section.dart';

const List<String> _kModulosD  = [
  'Inventario', 'Acervo', 'Ventas', 'Donaciones', 'Usuarios',
];
const List<String> _kAccionesD = [
  'Ver', 'Agregar', 'Editar', 'Eliminar',
  'Importar', 'Exportar', 'QR', 'Historial',
];

class UserDetailDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onEdit;
  const UserDetailDialog({required this.user, this.onEdit, super.key});

  @override
  State<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<UserDetailDialog> {
  final _viewModel = AddUserVM();

  Map<String, Map<String, bool>> _permisos = {
    for (final m in _kModulosD)
      m: {for (final a in _kAccionesD) a: false},
  };
  bool    _loading        = true;
  String? _expandedModulo;

  @override
  void initState() {
    super.initState();
    _cargarPermisos();
  }

  Future<void> _cargarPermisos() async {
    try {
      final perms = await _viewModel.getPermisos(widget.user.uid!);
      setState(() { _permisos = perms; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  int  _count(String m)    => _permisos[m]!.values.where((v) => v).length;
  bool _completo(String m) => _permisos[m]!.values.every((v) => v);
  bool _parcial(String m)  {
    final vals = _permisos[m]!.values;
    return vals.any((v) => v) && !vals.every((v) => v);
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return Stack(
      children: [
        // Overlay oscuro
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(color: const Color.fromRGBO(0, 0, 0, 0.45)),
        ),

        // Panel
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width:  480,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:    Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color:       Color(0x33000000),
                    blurRadius:  32,
                    offset:      Offset(-8, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color:        const Color(0xFF052B67),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              CupertinoIcons.person_fill,
                              color: Colors.white,
                              size:  20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Detalle de usuario',
                                  style: TextStyle(
                                      fontSize:   18,
                                      fontWeight: FontWeight.w700,
                                      color:      Color(0xFF1C2532))),
                              Text(u.email,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color:    Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        if (widget.onEdit != null)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onEdit!();
                            },
                            icon:  const Icon(CupertinoIcons.pencil,
                                size: 14),
                            label: const Text('Editar'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF052B67),
                              textStyle: const TextStyle(
                                  fontSize:   13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF6B7280)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // ── Cuerpo ───────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar + nombre + rol
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF3FB),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(u.roleIcon,
                                        style: const TextStyle(
                                            fontSize: 28)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(u.name,
                                    style: const TextStyle(
                                        fontSize:   16,
                                        fontWeight: FontWeight.w700,
                                        color:      Color(0xFF1C2532))),
                                const SizedBox(height: 4),
                                _roleBadge(u),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Info general ──────────────────────────────
                          PanelSection(
                            title: 'Información general',
                            children: [
                              _infoRow(CupertinoIcons.mail,
                                  'Correo', u.email),
                              const SizedBox(height: 8),
                              _infoRow(CupertinoIcons.calendar,
                                  'Registro',
                                  DateFormat('dd/MM/yyyy')
                                      .format(u.createAt)),
                              if (u.updatedAt != null) ...[
                                const SizedBox(height: 8),
                                _infoRow(CupertinoIcons.pencil,
                                    'Última edición',
                                    DateFormat('dd/MM/yyyy')
                                        .format(u.updatedAt!)),
                              ],
                              if (u.expiresAt != null) ...[
                                const SizedBox(height: 8),
                                _infoRow(
                                    CupertinoIcons.timer,
                                    'Expira',
                                    DateFormat('dd/MM/yyyy')
                                        .format(u.expiresAt!),
                                    valueColor:
                                        u.expiresAt!.isBefore(DateTime.now())
                                            ? Colors.redAccent
                                            : null),
                              ],
                              const SizedBox(height: 8),
                              _infoRow(
                                  CupertinoIcons.circle_fill,
                                  'Estado',
                                  u.status ? 'Activo' : 'Inactivo',
                                  valueColor: u.status
                                      ? const Color(0xFF2E7D32)
                                      : Colors.redAccent),
                            ],
                          ),

                          // ── Permisos ──────────────────────────────────
                          PanelSection(
                            title:            'Permisos por módulo',
                            showDividerAfter: false,
                            children: _loading
                                ? [
                                    const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                          child:
                                              CircularProgressIndicator()),
                                    )
                                  ]
                                : _kModulosD
                                    .map(_buildModuloTile)
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roleBadge(UserModel u) {
    final color = u.role == Role.adm
        ? const Color(0xFF052B67)
        : u.role == Role.staff
            ? const Color(0xFF2E7D32)
            : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(u.roleName,
          style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      color)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF6B7280))),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1C2532)),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildModuloTile(String modulo) {
    final completo  = _completo(modulo);
    final parcial   = _parcial(modulo);
    final count     = _count(modulo);
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
            onTap: () => setState(() =>
                _expandedModulo =
                    _expandedModulo == modulo ? null : modulo),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Ícono de estado (solo lectura)
                  Icon(
                    completo
                        ? CupertinoIcons.checkmark_circle_fill
                        : parcial
                            ? CupertinoIcons.minus_circle_fill
                            : CupertinoIcons.circle,
                    size:  18,
                    color: completo
                        ? const Color(0xFF2E7D32)
                        : parcial
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFCCCCCC),
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
                      child: Text('$count/${_kAccionesD.length}',
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
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor))),
              child: Column(
                children: _kAccionesD.map((accion) {
                  final activo   = _permisos[modulo]![accion]!;
                  final esUltima = accion == _kAccionesD.last;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
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
                        const SizedBox(width: 28),
                        Icon(_iconForAccion(accion),
                            size:  14,
                            color: activo
                                ? const Color(0xFF052B67)
                                : const Color(0xFFCCCCCC)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(accion,
                              style: TextStyle(
                                fontSize:   13,
                                fontWeight: activo
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: activo
                                    ? const Color(0xFF1C2532)
                                    : const Color(0xFF9CA3AF),
                              )),
                        ),
                        Icon(
                          activo
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.xmark_circle,
                          size:  15,
                          color: activo
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFCCCCCC),
                        ),
                      ],
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
void showUserDetailDialog(BuildContext context, UserModel user,
    {VoidCallback? onEdit}) {
  showGeneralDialog(
    context:            context,
    barrierDismissible: true,
    barrierLabel:       'Detalle de usuario',
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
          child: UserDetailDialog(user: user, onEdit: onEdit),
        ),
      );
    },
  );
}