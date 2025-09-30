import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';

class AddUserVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AddUserVM();

  /// AGREGAR USUARIO Firebase Auth + Firestore
  Future<void> addUsuario(UserModel user) async {
    final errors = user.validate();
    if (errors.isNotEmpty) {
      throw Exception(errors.join(', '));
    }

    try {
      // CREAR USUARIO EN Firebase Auth 
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      final uid = credential.user!.uid;

      // GUARDAR INFO EN Firestore 
      final userData = user.toMap();
      userData['uid'] = uid; 
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// OBTENER LOS USUARIOS
  Future<List<UserModel>> getUsuariosFirebase() async {
    try {
      final snapshot = await _firestore.collection('users').orderBy('name').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
