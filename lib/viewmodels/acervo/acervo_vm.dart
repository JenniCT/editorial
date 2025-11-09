import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diacritic/diacritic.dart';
import '../../widgets/global/dialog.dart';
import '../../models/book_m.dart';

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

        return CustomToast(
          title: title,
          message: message,
          color: color,
          icon: icon,
        );
      },
    );
  }

  /// Genera ID único basado en título, autor y año
  String generarIdAcervo(Book book) {
    final titulo = removeDiacritics(book.titulo.trim().toLowerCase());
    final autor = removeDiacritics(book.autor.trim().toLowerCase());
    final anio = book.anio.toString();
    return '$titulo$autor$anio'
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }

  /// Agregar libro como "acervo" (estado = false)
  Future<void> addAcervo(Book book, BuildContext context) async {
    try {
      final tempId = generarIdAcervo(book);

      final existing = await _firestore
          .collection('books')
          .where('idBook', isEqualTo: tempId)
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
      String? uploadedUrl = book.imagenUrl;
      if (book.imagenFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('book_images/$fileName');
        await ref.putFile(book.imagenFile!);
        uploadedUrl = await ref.getDownloadURL();
      }

      final user = FirebaseAuth.instance.currentUser;
      final registrador = user?.email ?? 'desconocido';
      final fecha = DateTime.now();

      // Aplicamos reglas de negocio
      final bookToSave = book.copyWith(
        imagenUrl: uploadedUrl,
        fechaRegistro: fecha,
        estado: false, 
        estante: 0,
        almacen: book.copias,
      );

      // Crear documento en "books"
      final docRef = await _firestore.collection('books').add({
        ...bookToSave.toMap(),
        'registradoPor': registrador,
        'fechaRegistro': fecha,
      });

      await docRef.update({'idBook': docRef.id});

      if (context.mounted) {
        _mostrarDialogo(
          context,
          title: '¡Registro exitoso!',
          message: 'El libro ha sido guardado correctamente en acervo.',
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
          message: 'No se pudo registrar el acervo. Intenta nuevamente.',
          color: Colors.redAccent,
          icon: Icons.error_outline,
        );
      }
    }
  }

  /// Stream de libros en estado false
  Stream<List<Book>> getAcervosStream() {
    return _firestore
        .collection('books')
        .where('estado', isEqualTo: false)
        .orderBy('titulo')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          if (snapshot.metadata.isFromCache) {
            return [];
          }

          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Book(
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
              imagenUrl: data['imagenUrl'],
              estado: data['estado'] ?? false,
              fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
              estante: data['estante'] ?? 0,
              almacen: data['almacen'] ?? 0,
              areaConocimiento: data['areaConocimiento'] ?? '',
              registradoPor: data['registradoPor'] ?? 'desconocido',
            );
          }).toList();
        });
  }

}
