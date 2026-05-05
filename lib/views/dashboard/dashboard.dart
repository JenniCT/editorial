import 'package:flutter/material.dart';
import '../../viewmodels/dashboard_vm.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = DashboardViewModel();
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1200;

    return Container(
      color: const Color(0xFFF6F8FC),
      child: FutureBuilder<DashboardStats>(
        future: vm.getStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error:\n${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Sin datos'),
            );
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bienvenido, Administrador',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                /// TOP GRID
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _topCards(stats),
                          const SizedBox(height: 20),
                          /*_alertsSection(stats),
                          const SizedBox(height: 20),
                          _chartsSection(),
                          const SizedBox(height: 20),*/
                          _movementsTable(stats),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    /// SIDEBAR DERECHA
                    if (isDesktop)
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _areasSection(stats),
                            const SizedBox(height: 20),
                            _inventorySummary(stats),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topCards(DashboardStats stats) {
    return Row(
      children: [
        Expanded(child: _card("Libros registrados", stats.totalBooks.toString(), Icons.book, Colors.blue, "Total de libros en el sistema")),
        const SizedBox(width: 16),
        Expanded(child: _card("Acervo total", stats.totalAcervo.toString(), Icons.library_books, Colors.green, "Total de items en el acervo")),
        const SizedBox(width: 16),
        Expanded(child: _card("Ventas del mes", "\$${stats.monthlySales.toStringAsFixed(0)}", Icons.monetization_on, Colors.orange, "Ingresos del mes actual")),
        const SizedBox(width: 16),
        Expanded(child: _card("Usuarios activos", stats.totalUsers.toString(), Icons.people, Colors.purple, "Total de usuarios registrados")),
      ],
    );
  }

  Widget _card(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: color,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              Text(
                '+12%',
                style: TextStyle(
                  color: color,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  /*
  Widget _alertsSection(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Alertas importantes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          Text("${stats.noStock} libros sin stock"),
          const SizedBox(height: 8),
          Text("${stats.lowStock} libros con stock bajo"),
        ],
      ),
    );
  }
  */
  
  /*
  Widget _chartsSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _box("Ingresos semanales"),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _box("Distribución por módulos"),
        ),
      ],
    );
  }
  */

  Widget _movementsTable(
    DashboardStats stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Movimientos recientes",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(2),
            },
            children: [
              /// HEADER
              const TableRow(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.all(8),
                    child: Text(
                      'Fecha',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.all(8),
                    child: Text(
                      'Tipo',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.all(8),
                    child: Text(
                      'Descripción',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.all(8),
                    child: Text(
                      'Libro',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.all(8),
                    child: Text(
                      'Cantidad',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.all(8),
                    child: Text(
                      'Usuario',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              ...stats.recentMovements.map(
                (m) => TableRow(
                  children: [
                    _tableCell(m.fecha),
                    _tableCell(m.tipo),
                    _tableCell(
                      m.descripcion,
                    ),
                    _tableCell(m.libro),
                    _tableCell(
                      m.cantidad,
                    ),
                    _tableCell(
                      m.usuario,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _areasSection(
    DashboardStats stats,
  ) {
    final sortedAreas =
        stats.areasCount.entries.toList()
          ..sort(
            (a, b) =>
                b.value.compareTo(a.value),
          );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Áreas de conocimiento",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ...sortedAreas.take(8).map(
            (area) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        const BoxDecoration(
                      color: Color(
                        0xFF2563EB,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      area.key,
                      style:
                          const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF3F4F6,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: Text(
                      area.value.toString(),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventorySummary(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen de inventario",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          Text("Total de libros: ${stats.totalBooks}"),
          Text("Total en stock: ${stats.totalStock}"),
          Text("Stock bajo: ${stats.lowStock}"),
          Text("Sin stock: ${stats.noStock}"),
        ],
      ),
    );
  }

  Widget _box(String title) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _tableCell(
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }

}