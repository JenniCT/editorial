import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<int> _getCount(bool estado) async {
    final aggregateQuery = await FirebaseFirestore.instance
        .collection('books')
        .where('estado', isEqualTo: estado)
        .count()
        .get();

    return aggregateQuery.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300, // 🟢 ancho máximo de la tarjeta
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 2, // relación aproximada ancho/alto
              ),
              children: [
                FutureBuilder<int>(
                  future: _getCount(true),
                  builder: (context, snapshot) {
                    return _DashboardCard(
                      title: 'Libros registrados',
                      value: snapshot.hasData ? snapshot.data.toString() : '...',
                      icon: Icons.book,
                      color: Colors.indigo,
                    );
                  },
                ),
                FutureBuilder<int>(
                  future: _getCount(false),
                  builder: (context, snapshot) {
                    return _DashboardCard(
                      title: 'Acervo',
                      value: snapshot.hasData ? snapshot.data.toString() : '...',
                      icon: Icons.library_books,
                      color: Colors.green,
                    );
                  },
                ),
                const _DashboardCard(
                  title: 'Ventas',
                  value: '\$1,250',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                ),
                const _DashboardCard(
                  title: 'Usuarios activos',
                  value: '15',
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.3),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // 🟢 ajusta al contenido
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
