import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../viewmodels/docs/import_vm.dart';

class ImportDialog extends StatefulWidget {
  final String entityName;
  final Future<void> Function(List<Map<String, dynamic>> data) onImportConfirmed;

  const ImportDialog({
    super.key,
    required this.entityName,
    required this.onImportConfirmed,
  });

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final ImportViewModel _importVM = ImportViewModel();
  List<Map<String, dynamic>>? _previewData;
  bool _isProcessing = false;

  Future<void> _handleFilePick() async {
    final data = await _importVM.pickAndParseExcel(context);
    if (data != null) {
      setState(() => _previewData = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Importar ${widget.entityName}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark, size: 20, color: Color(0xFF64748B)),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // ZONA DE CARGA O VISTA PREVIA
              if (_previewData == null)
                _buildUploadArea()
              else
                _buildPreviewArea(),

              const SizedBox(height: 24),

              // BOTONES DE ACCIÓN
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: (_previewData == null || _isProcessing) 
                      ? null 
                      : () async {
                        setState(() => _isProcessing = true);
                        await widget.onImportConfirmed(_previewData!);
                        if (mounted) Navigator.pop(context);
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C2532),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isProcessing 
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirmar Importación'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _handleFilePick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
        ),
        child: Column(
          children: const [
            Icon(CupertinoIcons.cloud_upload, size: 48, color: Color(0xFF64748B)),
            SizedBox(height: 12),
            Text('Haz clic para seleccionar un archivo .xlsx', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('Asegúrate de usar el formato oficial de exportación', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Se encontraron ${_previewData!.length} registros:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
              child: ListView.builder(
                itemCount: _previewData!.length,
                itemBuilder: (context, index) {
                  final item = _previewData![index];
                  return ListTile(
                    dense: true,
                    title: Text(item.values.first.toString()),
                    subtitle: Text(item.values.elementAt(1).toString()),
                    leading: const Icon(Icons.description_outlined, size: 20),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}