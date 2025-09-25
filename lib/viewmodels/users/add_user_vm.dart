import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';

class AddUserVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AddUserVM();

  /// Agregar usuario usando Firebase Auth + Firestore
  Future<void> addUsuario(UserModel user) async {
    final errors = user.validate();
    if (errors.isNotEmpty) {
      throw Exception(errors.join(', '));
    }

    try {
      // Crear usuario en Firebase Auth (genera UID automáticamente)
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      final uid = credential.user!.uid;

      // Guardar info en Firestore usando UID generado
      final userData = user.toMap();
      userData['uid'] = uid; // asegurarnos de usar UID real de Firebase
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todos los usuarios desde Firebase
  Future<List<UserModel>> getUsuariosFirebase() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
