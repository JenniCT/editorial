import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/book_m.dart';

// ================================================================
//  FUNCIÓN HELPER — úsala desde InventarioPage y AcervoPage
// ================================================================
void mostrarDetalleLibro(
  BuildContext context,
  Book book, {
  required void Function(Book) onUpdate,
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
          child: _DetallePanel(book: book, onUpdate: onUpdate),
        ),
      );
    },
  );
}


// ================================================================
//  PANEL LATERAL
// ================================================================
class _DetallePanel extends StatefulWidget {
  final Book book;
  final void Function(Book) onUpdate;

  const _DetallePanel({required this.book, required this.onUpdate});

  @override
  State<_DetallePanel> createState() => _DetallePanelState();
}

class _DetallePanelState extends State<_DetallePanel> {
  late Book book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }


  String _formatFecha(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatHora(DateTime? dt) {
    if (dt == null) return '-';
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final periodo = h >= 12 ? 'p.m.' : 'a.m.';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $periodo';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 420,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 32,
              offset: Offset(-8, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPortadaYTitulo(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildInfoGrid(),
                    const SizedBox(height: 20),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildStockRow(),
                    const SizedBox(height: 20),
                    _buildAreaBadge(),
                    const SizedBox(height: 28),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildBitacora(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF052B67),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(CupertinoIcons.book_fill, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Detalles del libro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C2532),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ── PORTADA + TÍTULO ─────────────────────────────────────────────
  Widget _buildPortadaYTitulo() {
    final hasUrl = book.imagenUrl != null && book.imagenUrl!.startsWith('http');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: hasUrl
              ? FadeInImage.assetNetwork(
                  placeholder: 'assets/images/sinportada.png',
                  image: book.imagenUrl!,
                  height: 130,
                  width: 90,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (_, _, _) => Image.asset(
                    'assets/images/sinportada.png',
                    height: 130,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/sinportada.png',
                  height: 130,
                  width: 90,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.titulo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2532),
                  height: 1.3,
                ),
              ),
              if (book.subtitulo != null && book.subtitulo!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  book.subtitulo!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _infoChip(Icons.person_outline_rounded, book.autor),
            ],
          ),
        ),
      ],
    );
  }

  // ── GRID DE INFO ─────────────────────────────────────────────────
  Widget _buildInfoGrid() {
    return Column(
      children: [
        _infoRow('Editorial', book.editorial),
        _infoRow('Colección', book.coleccion ?? '-'),
        Row(
          children: [
            Expanded(child: _infoRow('Año', book.anio.toString())),
            Expanded(child: _infoRow('Edición', book.edicion.toString())),
          ],
        ),
        _infoRow('ISBN', book.isbn ?? '-'),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C2532),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STOCK ROW ────────────────────────────────────────────────────
  Widget _buildStockRow() {
    return Row(
      children: [
        _stockItem(CupertinoIcons.square_stack_3d_up, 'Total', book.copias.toString()),
        const SizedBox(width: 24),
        _stockItem(CupertinoIcons.bookmark, 'Estante', book.estante.toString()),
        const SizedBox(width: 24),
        _stockItem(CupertinoIcons.cube_box, 'Almacén', book.almacen.toString()),
      ],
    );
  }

  Widget _stockItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text('$label:  ',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C2532),
          ),
        ),
      ],
    );
  }

  // ── ÁREA BADGE ───────────────────────────────────────────────────
  Widget _buildAreaBadge() {
    return Row(
      children: [
        const Icon(CupertinoIcons.tag, size: 14, color: Color(0xFF6B7280)),
        const SizedBox(width: 6),
        const Text(
          'Área de conocimiento:  ',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    book.areaConocimiento,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B21B6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── BITÁCORA ─────────────────────────────────────────────────────
  Widget _buildBitacora() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bitácora',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C2532),
          ),
        ),
        const SizedBox(height: 16),

        // CREACIÓN
        _buildBitacoraItem(
          titulo: 'Creado',
          fecha: _formatFecha(book.fechaRegistro),
          hora: _formatHora(book.fechaRegistro),
          usuario: book.registradoPor,
          labelUsuario: 'Creado por',
          isLast: false,
        ),

        // ÚLTIMA MODIFICACIÓN
        // Cuando tu modelo tenga fechaModificacion y modificadoPor,
        // reemplaza book.fechaRegistro y book.registradoPor abajo.
       _buildBitacoraItem(
          titulo: 'Última modificación',
          fecha: _formatFecha(book.fechaModificacion),
          hora: _formatHora(book.fechaModificacion ),
          usuario: book.modificadoPor ?? '-',
          labelUsuario: 'Modificado por',
          isLast: true,
        ),
      ],
    );
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
          // DOT + LÍNEA VERTICAL
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF052B67),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 2, color: const Color(0xFFDDE3EE)),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // CONTENIDO
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
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C2532),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _bitacoraRow('Fecha:', fecha),
                    const SizedBox(height: 5),
                    _bitacoraRow('Hora:', hora),
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
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C2532),
            ),
          ),
        ),
      ],
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────
  Widget _buildDivider() =>
      const Divider(color: Color(0xFFEEEEEE), height: 1);

  Widget _infoChip(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }
}


// ================================================================
//  CLASE LEGACY — mantiene compatibilidad con rutas existentes
// ================================================================
class DetalleLibroPage extends StatelessWidget {
  final Book book;
  final VoidCallback onBack;

  const DetalleLibroPage({
    required this.book,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarDetalleLibro(context, book, onUpdate: (_) {});
    });
    return Scaffold(
      backgroundColor: Colors.black45,
      body: GestureDetector(onTap: onBack),
    );
  }
}