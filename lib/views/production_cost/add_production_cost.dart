import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/global/textfield.dart';
import '../../models/production_cost.dart';
import '../../viewmodels/prodution_cost/production_cost_vm.dart';

class AddProductionCostDialog extends StatefulWidget {
  final String bookId;
  final Function(CostosProduccion) onAdd;

  const AddProductionCostDialog({
    required this.bookId,
    required this.onAdd,
    super.key,
  });

  @override
  State<AddProductionCostDialog> createState() =>
      _AddProductionCostDialogState();
}

class _AddProductionCostDialogState extends State<AddProductionCostDialog> {
  final _formKey = GlobalKey<FormState>();
  final CostosProduccionViewModel _viewModel = CostosProduccionViewModel();

  // Controllers para cada costo
  final TextEditingController _bondPaperController = TextEditingController();
  final TextEditingController _coatedPaperController = TextEditingController();
  final TextEditingController _laborController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _copyrightFeeController = TextEditingController();
  final TextEditingController _isbnFeeController = TextEditingController();
  final TextEditingController _electricityServiceController =
      TextEditingController();
  final TextEditingController _extraCost1Controller = TextEditingController();
  final TextEditingController _extraCost2Controller = TextEditingController();
  final TextEditingController _extraCost3Controller = TextEditingController();

  Future<void> _saveCost() async {
    if (_formKey.currentState!.validate()) {
      final cost = CostosProduccion(
        id: '',
        idBook: widget.bookId,
        papelBon: double.tryParse(_bondPaperController.text) ?? 0,
        couchel: double.tryParse(_coatedPaperController.text) ?? 0,
        manoObra: double.tryParse(_laborController.text) ?? 0,
        material: double.tryParse(_materialController.text) ?? 0,
        derechosAutor: double.tryParse(_copyrightFeeController.text) ?? 0,
        isbn: double.tryParse(_isbnFeeController.text) ?? 0,
        servicios: double.tryParse(_electricityServiceController.text) ?? 0,
        costoExtra1: double.tryParse(_extraCost1Controller.text) ?? 0,
        costoExtra2: double.tryParse(_extraCost2Controller.text) ?? 0,
        costoExtra3: double.tryParse(_extraCost3Controller.text) ?? 0,
        fechaRegistro: DateTime.now(),
        registradoPor: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
      );

      await _viewModel.agregarCosto(cost);
      widget.onAdd(cost);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _bondPaperController.dispose();
    _coatedPaperController.dispose();
    _laborController.dispose();
    _materialController.dispose();
    _copyrightFeeController.dispose();
    _isbnFeeController.dispose();
    _electricityServiceController.dispose();
    _extraCost1Controller.dispose();
    _extraCost2Controller.dispose();
    _extraCost3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(19, 38, 87, 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Agregar costos de producción',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _bondPaperController,
                        label: 'PAPEL BOND',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _coatedPaperController,
                        label: 'COUCHER',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _laborController,
                        label: 'MANO DE OBRA',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _materialController,
                        label: 'MATERIAL',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _copyrightFeeController,
                        label: 'DERECHOS DE AUTOR',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _isbnFeeController,
                        label: 'ISBN',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _electricityServiceController,
                        label: 'SERVICIOS',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _extraCost1Controller,
                        label: 'COSTO 1',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _extraCost2Controller,
                        label: 'COSTO 2',
                        isNumeric: true,
                      ),
                      CustomTextField(
                        controller: _extraCost3Controller,
                        label: 'COSTO 3',
                        isNumeric: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveCost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddProductionCostDialog(
  BuildContext context,
  String bookId,
  Function(CostosProduccion) onAdd,
) {
  showDialog(
    context: context,
    builder: (_) => AddProductionCostDialog(bookId: bookId, onAdd: onAdd),
  );
}
