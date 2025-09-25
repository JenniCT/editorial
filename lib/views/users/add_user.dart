import 'dart:ui';
import 'package:flutter/material.dart';

// MODELOS
import '../../models/user.dart';
// VIEWMODEL
import '../../viewmodels/users/add_user_vm.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  late final AddUserVM _viewModel;
  Role _selectedRole = Role.staff;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _viewModel = AddUserVM();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = DateTime.now().millisecondsSinceEpoch.toString();

    final user = UserModel(
      uid: uid,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      createAt: DateTime.now(),
      expiresAt: _selectedRole == Role.guest ? _expiresAt : null,
      role: _selectedRole,
      status: true,
    );

    try {
      await _viewModel.addUsuario(user); // Solo Firebase
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(19, 38, 87, 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color.fromRGBO(47, 65, 87, 0.3)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Agregar nuevo usuario",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Correo electrónico",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || !v.contains('@')
                        ? "Correo inválido"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? "Mínimo 6 caracteres"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Role>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: "Rol",
                      border: OutlineInputBorder(),
                    ),
                    items: Role.values
                        .where((r) => r != Role.adm)
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.toString().split('.').last),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedRole = val ?? Role.staff);
                    },
                  ),
                  if (_selectedRole == Role.guest) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _expiresAt != null
                                ? "Expira: ${_expiresAt!.toLocal()}".split(' ')[0]
                                : "Seleccionar fecha de expiración",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _pickDate,
                          child: const Text("Elegir fecha"),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(240, 91, 84, 1),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancelar"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed: _saveUser,
                        child: const Text("Guardar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showAddUserDialog(BuildContext context) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Agregar usuario",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return ScaleTransition(
        scale: curved,
        child: const AddUserDialog(),
      );
    },
  );
}
