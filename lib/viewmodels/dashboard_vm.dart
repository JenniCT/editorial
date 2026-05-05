import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardMovement {
  final String fecha;
  final String tipo;
  final String descripcion;
  final String libro;
  final String cantidad;
  final String usuario;

  DashboardMovement({
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.libro,
    required this.cantidad,
    required this.usuario,
  });
}

class DashboardStats {
  final int totalBooks;
  final int totalStock;
  final int totalUsers;
  final int totalAcervo;
  final int lowStock;
  final int noStock;
  final double monthlySales;

  /// Áreas de conocimiento
  final Map<String, int> areasCount;

  /// Movimientos recientes
  final List<DashboardMovement> recentMovements;

  DashboardStats({
    required this.totalBooks,
    required this.totalStock,
    required this.totalUsers,
    required this.totalAcervo,
    required this.lowStock,
    required this.noStock,
    required this.monthlySales,
    required this.areasCount,
    required this.recentMovements,
  });
}

class DashboardViewModel {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  Future<DashboardStats> getStats() async {
    /// =========================================
    /// BOOKS
    /// =========================================

    final booksSnapshot =
        await _db.collection('books').get();

    int totalBooks =
        booksSnapshot.docs.length;

    int totalStock = 0;
    int lowStock = 0;
    int noStock = 0;

    Map<String, int> areasCount = {};

    for (final doc in booksSnapshot.docs) {
      final data = doc.data();

      final copias =
          (data['copias'] ?? 0) as int;

      final area =
          (data['areaConocimiento'] ??
                  'Sin definir')
              .toString();

      totalStock += copias;

      if (copias == 0) {
        noStock++;
      } else if (copias <= 10) {
        lowStock++;
      }

      /// contar por área
      if (areasCount.containsKey(area)) {
        areasCount[area] =
            areasCount[area]! + 1;
      } else {
        areasCount[area] = 1;
      }
    }

    /// =========================================
    /// USERS
    /// =========================================

    final usersSnapshot =
        await _db.collection('users').get();

    final int totalUsers =
        usersSnapshot.docs.length;

    /// =========================================
    /// ACERVO
    /// =========================================

    final acervoSnapshot =
        await _db.collection('acervo').get();

    final int totalAcervo =
        acervoSnapshot.docs.length;

    /// =========================================
    /// SALES OF MONTH
    /// =========================================

    final salesSnapshot =
        await _db.collection('sales').get();

    double monthlySales = 0;
    final now = DateTime.now();

    for (final doc in salesSnapshot.docs) {
      final data = doc.data();

      final fecha =
          DateTime.tryParse(
                (data['fecha'] ?? '')
                    .toString(),
              ) ??
              DateTime.now();

      if (fecha.month == now.month &&
          fecha.year == now.year) {
        monthlySales +=
            ((data['total'] ?? 0) as num)
                .toDouble();
      }
    }

    /// =========================================
    /// MOVIMIENTOS RECIENTES
    /// =========================================

    List<DashboardMovement>
        recentMovements = [];

    /// ---------- VENTAS ----------
    final salesRecent =
        await _db
            .collection('sales')
            .orderBy(
              'fecha',
              descending: true,
            )
            .limit(5)
            .get();

    for (final doc in salesRecent.docs) {
      final data = doc.data();

      recentMovements.add(
        DashboardMovement(
          fecha:
              (data['fecha'] ?? '')
                  .toString(),
          tipo: 'Venta',
          descripcion:
              'Venta mostrador',
          libro:
              (data['titulo'] ?? '')
                  .toString(),
          cantidad:
              (data['cantidad'] ?? 0)
                  .toString(),
          usuario:
              (data['userEmail'] ??
                      '')
                  .toString(),
        ),
      );
    }

    /// ---------- DONACIONES ----------
    final donationsRecent =
        await _db
            .collection('donations')
            .orderBy(
              'fecha',
              descending: true,
            )
            .limit(5)
            .get();

    for (final doc in donationsRecent.docs) {
      final data = doc.data();

      recentMovements.add(
        DashboardMovement(
          fecha:
              (data['fecha'] ?? '')
                  .toString(),
          tipo: 'Donación',
          descripcion:
              'Ingreso por donación',
          libro:
              (data['titulo'] ?? '')
                  .toString(),
          cantidad:
              (data['cantidad'] ?? 0)
                  .toString(),
          usuario:
              (data['userEmail'] ??
                      '')
                  .toString(),
        ),
      );
    }

    /// ordenar globalmente
    recentMovements.sort(
      (a, b) =>
          b.fecha.compareTo(a.fecha),
    );

    /// limitar a 8
    recentMovements =
        recentMovements.take(8).toList();

    /// =========================================
    /// RETURN
    /// =========================================

    return DashboardStats(
      totalBooks: totalBooks,
      totalStock: totalStock,
      totalUsers: totalUsers,
      totalAcervo: totalAcervo,
      lowStock: lowStock,
      noStock: noStock,
      monthlySales: monthlySales,
      areasCount: areasCount,
      recentMovements:
          recentMovements,
    );
  }
}