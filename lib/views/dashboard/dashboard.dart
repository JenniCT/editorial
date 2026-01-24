import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 1100;
    final bool isTablet = width > 700 && width <= 1100;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
            ),
            const SizedBox(height: 24),

            // 1. TARJETAS DINÁMICAS (4 en Desktop, 2x2 en Tablet/Móvil)
            _buildResponsiveCards(isDesktop, isTablet),

            const SizedBox(height: 24),

            // 2. GRÁFICAS QUE ABARCAN TODOS EL ANCHO
            _buildResponsiveCharts(isDesktop),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE TARJETAS ALINEADAS ---
  Widget _buildResponsiveCards(bool isDesktop, bool isTablet) {
    // Si es desktop, usamos una fila con Expanded para que ocupen todo el ancho equitativamente
    if (isDesktop) {
      return Row(
        children: [
          _cardItem('Libros registrados', '191', Icons.book_outlined, const Color(0xFF6366F1)),
          const SizedBox(width: 16),
          _cardItem('Acervo Total', '300', Icons.library_books_outlined, const Color(0xFF10B981)),
          const SizedBox(width: 16),
          _cardItem('Ventas del mes', '\$1,250', Icons.shopping_cart_outlined, const Color(0xFFF59E0B)),
          const SizedBox(width: 16),
          _cardItem('Usuarios activos', '15', Icons.people_outline, const Color(0xFF8B5CF6)),
        ],
      );
    } 

    // Si es móvil o tablet, usamos un GridView con altura fija para evitar desbordes
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, // Siempre 2 de ancho
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isTablet ? 2.5 : 1.5, // Ajusta la proporción según el dispositivo
      children: [
        _cardItemSimple('Libros registrados', '191', Icons.book_outlined, const Color(0xFF6366F1)),
        _cardItemSimple('Acervo Total', '300', Icons.library_books_outlined, const Color(0xFF10B981)),
        _cardItemSimple('Ventas del mes', '\$1,250', Icons.shopping_cart_outlined, const Color(0xFFF59E0B)),
        _cardItemSimple('Usuarios activos', '15', Icons.people_outline, const Color(0xFF8B5CF6)),
      ],
    );
  }

  // Tarjeta para Desktop (con Expanded)
  Widget _cardItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: _baseCard(title, value, icon, color),
    );
  }

  // Tarjeta para Móvil (sin Expanded para el Grid)
  Widget _cardItemSimple(String title, String value, IconData icon, Color color) {
    return _baseCard(title, value, icon, color);
  }

  Widget _baseCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              Text('+12%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // --- LÓGICA DE GRÁFICAS ALINEADAS ---
  Widget _buildResponsiveCharts(bool isDesktop) {
    final chartContent = [
      _ChartContainer(
        title: 'Ingresos Semanales',
        subtitle: 'Incremento del 5% vs semana pasada',
        child: _buildAreaChart(),
      ),
      _ChartContainer(
        title: 'Distribución',
        subtitle: 'Actividad por módulos',
        child: _buildDoughnutChart(),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 2, child: chartContent[0]),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: chartContent[1]),
        ],
      );
    }

    return Column(
      children: [
        chartContent[0],
        const SizedBox(height: 24),
        chartContent[1],
      ],
    );
  }

  // Gráfica de "Área" Estilizada
  Widget _buildAreaChart() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(
        painter: AreaPainter(),
      ),
    );
  }

  // Gráfica de Dona Estilizada
  Widget _buildDoughnutChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140, height: 140,
            child: CircularProgressIndicator(
              value: 0.7,
              strokeWidth: 15,
              backgroundColor: const Color.fromRGBO(158, 158, 158, 0.1),
              color: const Color(0xFF6366F1),
              strokeCap: StrokeCap.round,
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('70%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Eficiencia', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

// --- PINTORES PARA GRÁFICAS MÁS BONITAS ---
class AreaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(99, 102, 241, 0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.4, size.width * 0.4, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.9, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- CONTENEDOR DE GRÁFICA ---
class _ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _ChartContainer({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }
}