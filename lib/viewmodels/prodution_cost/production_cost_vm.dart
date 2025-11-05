import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/production_cost.dart';

class CostosProduccionViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CostosProduccion>> getCostosPorLibro(String idBook) {
    return _db
        .collection("costos_produccion")
        .where("idBook", isEqualTo: idBook)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CostosProduccion.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> agregarCosto(CostosProduccion costo) async {
    await _db.collection("costos_produccion").add(costo.toMap());
  }
}
