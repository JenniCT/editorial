import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// MODELOS
import '../../models/book_m.dart';
import '../../models/sale_m.dart';
// VIEWMODEL
import '../../viewmodels/sales_vm.dart';

class SellDialog extends StatefulWidget {
  final Book book;
  final Function(Book) onSold;

  const SellDialog({required this.book, required this.onSold, super.key});

  @override
  SellDialogState createState() => SellDialogState();
}

class SellDialogState extends State<SellDialog> {
  final _cantidadController = TextEditingController(text: '1');
  final _lugarController = TextEditingController();
  final SalesViewModel _salesVM = SalesViewModel();
  double total = 0;

  @override
  void initState() {
    super.initState();
    total = widget.book.precio;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vender libro'),
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          int cantidad = int.tryParse(_cantidadController.text) ?? 1;
          if (cantidad > widget.book.copias) cantidad = widget.book.copias;
          total = cantidad * widget.book.precio;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Título: ${widget.book.titulo}'),
              Text('Autor: ${widget.book.autor}'),
              const SizedBox(height: 12),
              TextField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad a vender',
                  hintText: 'Máx ${widget.book.copias}',
                ),
                onChanged: (value) {
                  int nuevaCantidad = int.tryParse(value) ?? 1;
                  if (nuevaCantidad > widget.book.copias) {
                    nuevaCantidad = widget.book.copias;
                    _cantidadController.text = widget.book.copias.toString();
                  }
                  setStateDialog(() => total = nuevaCantidad * widget.book.precio);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lugarController,
                decoration: const InputDecoration(
                  labelText: 'Lugar de venta',
                  hintText: 'Ej: Librería Central',
                ),
              ),
              const SizedBox(height: 12),
              Text('Total: \$${total.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            int cantidadFinal = int.tryParse(_cantidadController.text) ?? 1;
            if (cantidadFinal <= 0 || cantidadFinal > widget.book.copias) return;

            final lugar = _lugarController.text.trim();
            if (lugar.isEmpty) return;

            final user = FirebaseAuth.instance.currentUser;

            final sale = Sale(
              bookId: widget.book.id!,
              titulo: widget.book.titulo,
              autor: widget.book.autor,
              cantidad: cantidadFinal,
              total: cantidadFinal * widget.book.precio,
              fecha: DateTime.now(),
              userId: user?.uid ?? 'anonimo',
              userEmail: user?.email ?? 'anonimo',
              lugar: lugar,
            );

            // Registrar venta en Firestore
            await _salesVM.addSale(sale);

            // Crear nuevo Book con copias actualizadas
            final updatedBook = widget.book.copyWith(
              copias: widget.book.copias - cantidadFinal,
            );

            // Mandar Book actualizado al callback para refrescar UI
            widget.onSold(updatedBook);

            Navigator.pop(context);
          },
          child: const Text('Vender'),
        ),
      ],
    );
  }
}
