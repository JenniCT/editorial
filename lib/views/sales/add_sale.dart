import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// MODELOS
import '../../models/book_m.dart';
import '../../models/sale_m.dart';
// VIEWMODEL
import '../../viewmodels/market/sales_vm.dart';
// WIDGETS
import '../../widgets/global/textfield.dart';

class SellDialog extends StatefulWidget {
  final Book book;
  final Function(Book) onSold;

  const SellDialog({required this.book, required this.onSold, super.key});

  @override
  State<SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<SellDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController =
      TextEditingController(text: '1');
  final TextEditingController _lugarController = TextEditingController();

  late final SalesViewModel _salesVM;
  double total = 0; // Total por defecto 0

  @override
  void initState() {
    super.initState();
    _salesVM = SalesViewModel();
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;

    final cantidadFinal = int.tryParse(_cantidadController.text) ?? 1;
    if (cantidadFinal <= 0 || cantidadFinal > widget.book.copias) return;

    final lugar = _lugarController.text.trim();
    if (lugar.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    final sale = Sale(
      bookId: widget.book.id!,
      titulo: widget.book.titulo,
      autor: widget.book.autor,
      cantidad: cantidadFinal,
      fecha: DateTime.now(),
      userId: user?.uid ?? 'anonimo',
      userEmail: user?.email ?? 'anonimo',
      lugar: lugar,
      total: total,
    );

    try {
      await _salesVM.addSale(sale);

      final updatedBook = widget.book.copyWith(
        copias: widget.book.copias - cantidadFinal,
      );

      widget.onSold(updatedBook);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al registrar venta: $e")),
        );
      }
    }
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
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(19, 38, 87, 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color.fromRGBO(47, 65, 87, 0.3),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Registrar venta",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Libro: ${widget.book.titulo}\nAutor: ${widget.book.autor}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _cantidadController,
                    keyboardType: TextInputType.number,
                    label: "Cantidad a vender (máx. ${widget.book.copias})",
                    validator: (v) {
                      final val = int.tryParse(v ?? "");
                      if (val == null || val <= 0) return "Cantidad inválida";
                      if (val > widget.book.copias) return "Excede copias disponibles";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _lugarController,
                    label: "Lugar de la venta",
                    validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Total: \$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(240, 91, 84, 1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancelar"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _saveSale,
                        child: const Text("Registrar"),
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

Future<void> showSellDialog(
    BuildContext context, Book book, Function(Book) onSold) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Registrar venta",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _,_) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return ScaleTransition(
        scale: curved,
        child: SellDialog(book: book, onSold: onSold),
      );
    },
  );
}
