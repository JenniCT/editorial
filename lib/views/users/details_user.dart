import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../viewmodels/users/details_user_vm.dart';
import '../../widgets/global/background.dart';

class DetailsUserPage extends StatefulWidget {
  final UserModel usuario;
  final VoidCallback onBack;

  const  DetailsUserPage({
    required this.usuario,
    required this.onBack,
    super.key,
  });

  @override
  State<DetailsUserPage> createState() => _DetailsUserPageState();
}

class _DetailsUserPageState extends State<DetailsUserPage> {
  late UserModel usuario;
  late DetalleUsuarioVM viewModel;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
    viewModel = DetalleUsuarioVM(usuario: usuario);
  }

  void _updateUsuario(UserModel updatedUser) {
    setState(() {
      usuario = updatedUser;
      viewModel = DetalleUsuarioVM(usuario: usuario);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Detalles del Usuario',
          style: TextStyle(fontSize: 24, fontFamily: 'Roboto'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: widget.onBack,
        ),
      ),
      body: Stack(
        children: [
          const BackgroundCircles(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: isMobile
                  ? _buildCardMovil(context)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCardDesktop(context)),
                        const SizedBox(width: 24),
                        _buildBotoneraVertical(context),
                      ],
                    ),
            ),
          ),
        ],
      )
      
      
    );
  }

  /// Tarjeta para móvil
  Widget _buildCardMovil(BuildContext context) {
    return Column(
      children: [
        _buildCardEstilizada(context),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.0,
          runSpacing: 12.0,
          children: _accionesPrincipales(context),
        ),
      ],
    );
  }

  /// Tarjeta para escritorio
  Widget _buildCardDesktop(BuildContext context) {
    return _buildCardEstilizada(context);
  }

  Widget _buildCardEstilizada(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(47, 65, 87, 0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*CircleAvatar(
                radius: 60,
                backgroundImage: usuario.avatarUrl != null
                    ? NetworkImage(usuario.avatarUrl!)
                    : const AssetImage("assets/user_placeholder.png")
                        as ImageProvider,
              ),*/
              const SizedBox(width: 24),
              Expanded(child: _buildDetallesUsuario()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetallesUsuario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          usuario.name,
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          usuario.email,
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 24),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildRow("Rol", usuario.role.toString().split('.').last),
            _buildRow("Estado", usuario.status ? "Activo" : "Inactivo"),
            _buildRow("Creado", viewModel.formatDate(usuario.createAt)),
            _buildRow(
                "Expira",
                usuario.expiresAt != null
                    ? viewModel.formatDate(usuario.expiresAt!)
                    : "No asignado"),
          ],
        ),
      ],
    );
  }

  TableRow _buildRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  /// Botones principales (Editar, Dar de baja, etc.)
  List<Widget> _accionesPrincipales(BuildContext context) {
    return [
      _buildActionButton(Icons.edit, "Editar", color: Colors.orange, onPressed: () {
        viewModel.editarUsuario(context, _updateUsuario);
      }),
      _buildActionButton(Icons.remove_circle, "Dar de baja", color: Colors.red),
      _buildActionButton(Icons.download, "Exportar", color: Colors.blue),
      _buildActionButton(Icons.qr_code_2, "QR", color: Colors.purple),
      _buildActionButton(Icons.history, "Historial", color: Colors.black),
    ];
  }

  Widget _buildBotoneraVertical(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _accionesPrincipales(context)
          .map((btn) => Padding(padding: const EdgeInsets.only(bottom: 12), child: btn))
          .toList(),
    );
  }

  Widget _buildActionButton(IconData icon, String label,
      {Color? color, VoidCallback? onPressed}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 160,
          height: 48,
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.4),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onPressed ?? () {},
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
