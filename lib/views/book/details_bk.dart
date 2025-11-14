import 'dart:ui';
import 'package:editorial/views/donation/add_done.dart';
import 'package:flutter/material.dart';
import '../../models/book_m.dart';
//VISTAS
import '../basic/qr/qr_v.dart';
import '../book/edit_bk.dart';
import '../book/history_bk.dart';
import '../sales/add_sale.dart';
import '../production_cost/production_cost.dart';

class DetalleLibroPage extends StatefulWidget {
  final Book book;
  final VoidCallback onBack;
  const DetalleLibroPage({required this.book, required this.onBack, super.key});

  @override
  DetalleLibroPageState createState() => DetalleLibroPageState();
}

class DetalleLibroPageState extends State<DetalleLibroPage> {
  late Book book;
  late VoidCallback onBack;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    onBack = widget.onBack; 
  }

  // Método para actualizar el libro cuando se edite
  void _updateBook(Book updatedBook) {
    setState(() {
      book = updatedBook;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Detalles del Libro',
          style: TextStyle(fontSize: 24, fontFamily: 'Roboto'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ANCHO APROPIADO
            final minWidth = constraints.maxWidth;
            final maxWidth = isMobile
                ? (constraints.maxWidth < 800 ? 800.0 : constraints.maxWidth)
                : constraints.maxWidth;

            return SingleChildScrollView(
              // SCROLL VERTICAL
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                  ),
                  child: isMobile
                      ? _buildTarjetaMovil(
                          context,
                          book,
                          availableWidth: constraints.maxWidth,
                        )
                      : _buildTarjetaEscritorio(context, book),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTarjetaMovil(
    BuildContext context,
    Book book, {
    required double availableWidth,
  }) {
    // SE FORZA UN ANCHO MÍNIMO
    final containerWidth = availableWidth < 600 ? 700.0 : availableWidth;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: containerWidth,
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPortada(book, height: 300, width: 200),
                    const SizedBox(height: 24),
                    _buildDetalles(book),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // BOTONES FUERA DE LA TARJETA
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            _buildActionButton(
              context,
              Icons.edit,
              'Editar',
              color: const Color.fromRGBO(255, 171, 64, 0.6),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      EditBookDialog(book: book, onUpdate: _updateBook),
                );
              },
            ),
            _buildActionButton(
              context,
              Icons.attach_money,
              'Vender',
              color: const Color.fromRGBO(76, 175, 80, 0.6),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => SellDialog(
                    book: book,
                    onSold: (Book updatedBook) {
                      setState(() {
                        // ACTUALIZA EL LIBRO ACTUAL
                        book = updatedBook;
                      });
                    },
                  ),
                );
              },
            ),
            _buildActionButton(
              context, 
              Icons.volunteer_activism_rounded,
              'Donar',
              color: const Color.fromRGBO(255, 20, 147, 0.6),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => DonateDialog(
                  book: book,
                  onDonated: (Book updatedBook) {
                    setState(() {
                      // Actualiza el libro actual con el Book devuelto
                      book = updatedBook;
                    });
                  },
                ),
                );
              },
            ),
            _buildActionButton(
              context,
              Icons.remove_circle,
              'Dar de baja',
              color: const Color.fromRGBO(255, 0, 0, 0.6),
            ),
            _buildActionButton(
              context,
              Icons.download,
              'Descargar',
              color: const Color.fromRGBO(0, 123, 255, 0.6),
            ),
            _buildActionButton(
              context,
              Icons.qr_code_2,
              'Descargar QR',
              color: const Color.fromRGBO(138, 43, 226, 0.6),
              onPressed: () {
                showBookQrDialog(context, book);
              },
            ),
            _buildActionButton(
              context,
              Icons.history,
              'Historial',
              color: const Color.fromRGBO(0, 0, 0, 0.6),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistorialPage(idBook: book.id!),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTarjetaEscritorio(BuildContext context, book) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1000.0,
              maxHeight: 700.0,
            ),
            child: _buildTarjetaEstilizada(book),
          ),
        ),
        const SizedBox(width: 24),
        _buildBotoneraVertical(context),
      ],
    );
  }

  Widget _buildTarjetaEstilizada(Book book) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortada(book, height: 500, width: 300),
                const SizedBox(width: 32),
                Expanded(child: _buildDetalles(book)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortada(
    Book book, {
    required double height,
    required double width,
  }) {
    final hasUrl = book.imagenUrl != null && book.imagenUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: hasUrl
          ? FadeInImage.assetNetwork(
              placeholder: 'assets/sinportada.png',
              image: book.imagenUrl!,
              height: height,
              width: width,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/sinportada.png',
                  height: height,
                  width: width,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              'assets/sinportada.png',
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildDetalles(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.titulo,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (book.subtitulo != null && book.subtitulo!.isNotEmpty)
          Text(
            book.subtitulo!,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
        const SizedBox(height: 24),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildRow('Autor', book.autor),
            _buildRow('Editorial', book.editorial),
            _buildRow('Colección', book.coleccion ?? '-'),
            _buildRow('Año', book.anio.toString()),
            _buildRow('ISBN', book.isbn ?? '-'),
            _buildRow('Edición', book.edicion.toString()),
            _buildRow('Total', book.copias.toString()),
            _buildRow('Estante', book.estante.toString()),
            _buildRow('Almacén', book.almacen.toString()),
            _buildRow('Área', book.areaConocimiento),
          ],
        ),
      ],
    );
  }

  TableRow _buildRow(String label, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value?.toString() ?? '-',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildBotoneraVertical(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildActionButton(
          context,
          Icons.edit,
          'Editar',
          color: const Color.fromRGBO(255, 171, 64, 0.6),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  EditBookDialog(book: book, onUpdate: _updateBook),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          Icons.attach_money,
          'Vender',
          color: const Color.fromRGBO(76, 175, 80, 0.6),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => SellDialog(
              book: book,
              onSold: (Book updatedBook) {
                setState(() {
                  // Actualiza el libro actual con el Book devuelto
                  book = updatedBook;
                });
              },
            ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context, 
          Icons.volunteer_activism_rounded,
          'Donar',
          color: const Color.fromRGBO(255, 20, 147, 0.6),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => DonateDialog(
              book: book,
              onDonated: (Book updatedBook) {
                setState(() {
                  // Actualiza el libro actual con el Book devuelto
                  book = updatedBook;
                });
              },
            ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          Icons.remove_circle,
          'Dar de baja',
          color: const Color.fromRGBO(255, 0, 0, 0.6),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          Icons.attach_money,
          'Costos',
          color: const Color.fromRGBO(0, 123, 255, 0.6),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CostosProduccionPage(idBook: book.id!),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          Icons.qr_code_2,
          'Descargar QR',
          color: const Color.fromRGBO(138, 43, 226, 0.6),
          onPressed: () {
            showBookQrDialog(context, book);
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          Icons.history,
          'Historial',
          color: const Color.fromRGBO(0, 0, 0, 0.6),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistorialPage(idBook: book.id!),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 160,
          height: 48,
          decoration: BoxDecoration(
            color: (color ?? Colors.white),
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
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}