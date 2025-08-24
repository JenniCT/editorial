import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/dialog.dart';
import '../models/book_m.dart';

class BookViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// GENERA UN ID ÚNICO PARA EL LIBRO BASADO EN TÍTULO, AUTOR Y AÑO
  String generarIdLibro(Book book) {
    final base = '${book.titulo}_${book.autor}_${book.anio}';
    return base.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  /// AGREGA UN LIBRO SI NO EXISTE PREVIAMENTE
  Future<void> addBook(Book book, BuildContext context) async {
    try {
      final idLibro = generarIdLibro(book);

      final existing = await _firestore
          .collection('books')
          .where('idLibro', isEqualTo: idLibro)
          .get();

      if (existing.docs.isNotEmpty) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => const CustomDialog(
              title: 'Registro duplicado',
              message: 'Ya existe un libro con ese título, autor y año.',
              color: Colors.orangeAccent,
              icon: Icons.warning_amber_rounded,
            ),
          );
        }
        return;
      }

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

      final bookToSave = book.copyWith(
        imagenUrl: uploadedUrl,
        fechaRegistro: fecha,
      );

      await _firestore.collection('books').add({
        ...bookToSave.toMap(),
        'idLibro': idLibro,
        'registradoPor': registrador,
        'fechaRegistro': fecha,
      });

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => const CustomDialog(
            title: '¡Registro exitoso!',
            message: 'El libro ha sido guardado correctamente.',
            color: Colors.green,
            icon: Icons.check_circle_outline,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e, stackTrace) {
      debugPrint('Error al subir imagen o guardar libro: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => const CustomDialog(
            title: 'Error',
            message: 'No se pudo registrar el libro. Intenta nuevamente.',
            color: Colors.redAccent,
            icon: Icons.error_outline,
          ),
        );
      }
    }
  }
  /// LIBROS ORDENADOS
  Stream<List<Book>> getBooksStream() {
    return _firestore
        .collection('books')
        .orderBy('titulo', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Book(
              id: doc.id,
              titulo: data['titulo'] ?? '',
              autor: data['autor'] ?? '',
              subtitulo: data['subtitulo'],
              editorial: data['editorial'] ?? '',
              coleccion: data['coleccion'],
              anio: data['anio'] ?? 0,
              isbn: data['isbn'],
              edicion: data['edicion'] ?? 0,
              copias: data['copias'] ?? 0,
              precio: (data['precio'] ?? 0).toDouble(),
              imagenUrl: (data['imagenUrl'] ?? 'assets/sinportada.png'),
              estado: data['estado'] ?? true,
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