import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diacritic/diacritic.dart';
import '../widgets/global/dialog.dart';
import '../models/acervo_bk.dart';

class AcervoViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  void _mostrarDialogo(
    BuildContext context, {
    required String title,
    required String message,
    required Color color,
    required IconData icon,
    bool autoCerrar = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        if (autoCerrar) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) Navigator.of(context).pop();
          });
        }

        return CustomDialog(
          title: title,
          message: message,
          color: color,
          icon: icon,
        );
      },
    );
  }

  /// GENERA ID ÚNICO
  String generarIdAcervo(Acervo acervo) {
    final titulo = removeDiacritics(acervo.titulo.trim().toLowerCase());
    final autor = removeDiacritics(acervo.autor.trim().toLowerCase());
    final anio = acervo.anio.toString();
    return '$titulo$autor$anio'
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }


  /// AGREGAR ACERVO
  Future<void> addAcervo(Acervo acervo, BuildContext context) async {
    try {
      // ID temporal solo para verificar duplicados
      final tempId = generarIdAcervo(acervo);

      final existing = await _firestore
          .collection('acervo')
          .where('idAcervo', isEqualTo: tempId)
          .get();

      if (existing.docs.isNotEmpty) {
        if (context.mounted) {
          _mostrarDialogo(
            context,
            title: 'Registro duplicado',
            message: 'Ya existe un libro con ese título, autor y año.',
            color: Colors.orangeAccent,
            icon: Icons.warning_amber_rounded,
            autoCerrar: false,
          );
        }
        return;
      }

      // Subir imagen si aplica
      String? uploadedUrl = acervo.imagenUrl;
      if (acervo.imagenFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('acervo_images/$fileName');
        await ref.putFile(acervo.imagenFile!);
        uploadedUrl = await ref.getDownloadURL();
      }

      final user = FirebaseAuth.instance.currentUser;
      final registrador = user?.email ?? 'desconocido';
      final fecha = DateTime.now();

      final acervoToSave = acervo.copyWith(
        imagenUrl: uploadedUrl,
        fechaRegistro: fecha,
      );

      // Crear documento y dejar que Firebase genere el UID
      final docRef = await _firestore.collection('acervo').add({
        ...acervoToSave.toMap(),
        'registradoPor': registrador,
        'fechaRegistro': fecha,
      });

      // Actualizar idAcervo con el UID generado
      await docRef.update({'idAcervo': docRef.id});

      if (context.mounted) {
        _mostrarDialogo(
          context,
          title: '¡Registro exitoso!',
          message: 'El libro ha sido guardado correctamente.',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error al subir imagen o guardar acervo: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        _mostrarDialogo(
          context,
          title: 'Error',
          message: 'No se pudo registrar el libro. Intenta nuevamente.',
          color: Colors.redAccent,
          icon: Icons.error_outline,
        );
      }
    }
  }

  /// STREAM DE ACERVO
  Stream<List<Acervo>> getAcervosStream() {
    return _firestore
        .collection('acervo')
        .orderBy('titulo')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Acervo(
              id: doc.id,
              titulo: data['titulo'] ?? '',
              subtitulo: data['subtitulo'] ?? '',
              autor: data['autor'] ?? '',
              editorial: data['editorial'] ?? '',
              coleccion: data['coleccion'] ?? '',
              anio: data['anio'] ?? 0,
              isbn: data['isbn'] ?? '',
              edicion: data['edicion'] ?? 0,
              copias: data['copias'] ?? 0,
              precio: (data['precio'] ?? 0).toDouble(),
              imagenUrl: data['imagenUrl'],
              estado: data['estado'] ?? true,
              fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
              areaConocimiento: data['areaConocimiento'] ?? '',
              registradoPor: data['registradoPor'] ?? 'desconocido',
            );
          }).toList(),
        );
  }
}
