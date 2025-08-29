import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diacritic/diacritic.dart';
import '../widgets/dialog.dart';
//MODELOS
import '../models/book_m.dart';
import '../models/history_bk.dart';

class BookViewModel {
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

  /// GENERA UN ID ÚNICO PARA EL LIBRO BASADO EN TÍTULO, AUTOR Y AÑO
  String generarIdLibro(Book book) {
    final titulo = removeDiacritics(book.titulo.trim().toLowerCase());
    final autor = removeDiacritics(book.autor.trim().toLowerCase());
    final anio = book.anio.toString();

    final base = '$titulo$autor$anio';
    return base
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }

  /// AGREGA UN LIBRO SI NO EXISTE PREVIAMENTE
  Future<void> addBook(Book book, BuildContext context) async {
    try {
      final idLibro = generarIdLibro(book);
      debugPrint('ID generado: $idLibro');

      final existing = await _firestore
          .collection('books')
          .where('idLibro', isEqualTo: idLibro)
          .get();
      
      //  SI HAY DUPLICADOS, MOSTRAR DIÁLOGO SIN CERRAR EL PRINCIPAL
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

      // CONTINUAR CON EL REGISTRO
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

      // CERRAR DIÁLOGO PRINCIPAL SOLO DESPUÉS DEL ÉXITO
      if (context.mounted) {
        if (context.mounted) {
            _mostrarDialogo(
              context,
              title: '¡Registro exitoso!',
              message: 'El libro ha sido guardado correctamente.',
              color: Colors.green,
              icon: Icons.check_circle_outline,
            );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error al subir imagen o guardar libro: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        // EN CASO DE ERROR, CERRAR EL DIÁLOGO PRINCIPAL Y MOSTRAR ERROR
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            _mostrarDialogo(
              context,
              title: 'Error',
              message: 'No se pudo registrar el libro. Intenta nuevamente.',
              color: Colors.redAccent,
              icon: Icons.error_outline,
            );
          }
        });
      }
    }
  }

  /// EDITAR LIBRO EXISTENTE
  Future<void> editBook(Book book, BuildContext context) async {
    try {
      if (book.id == null) throw Exception("El libro no tiene ID para editar.");

      String? uploadedUrl = book.imagenUrl;

      if (book.imagenFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('book_images/$fileName');
        await ref.putFile(book.imagenFile!);
        uploadedUrl = await ref.getDownloadURL();
      }

      final updatedBook = book.copyWith(imagenUrl: uploadedUrl);
      final nuevo = updatedBook.toMap();

      // OBTENER DATOS ANTERIORES
      final docSnapshot = await _firestore.collection('books').doc(book.id).get();
      final datosAnteriores = docSnapshot.data();

      // DETECTAR CAMBIOS
      final cambios = <String, dynamic>{};
      datosAnteriores?.forEach((key, valorAnterior) {
        final valorNuevo = nuevo[key];
        if (valorNuevo != null && valorNuevo != valorAnterior) {
          cambios[key] = '$valorAnterior → $valorNuevo';
        }
      });

      // ACTUALIZAR LIBRO
      await _firestore.collection('books').doc(book.id).update(nuevo);

      // HISTORIAL CON CAMBIOS
      if (cambios.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        final editor = user?.email ?? 'desconocido';
        final fechaEdicion = DateTime.now();

        await _firestore.collection('history').add({
          'idLibro': book.id,
          'editadoPor': editor,
          'fechaEdicion': fechaEdicion,
          'cambios': cambios,
          'accion' : 'Modificado',
        });
      }

      // MENSAJE DE ÉXITO
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            _mostrarDialogo(
              context,
              title: '¡Edición exitosa!',
              message: 'El libro ha sido actualizado correctamente.',
              color: Colors.green,
              icon: Icons.check_circle_outline,
            );
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error al editar libro: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            _mostrarDialogo(
              context,
              title: 'Error',
              message: 'No se pudo actualizar el libro. Intenta nuevamente.',
              color: Colors.redAccent,
              icon: Icons.error_outline,
            );
          }
        });
      }
    }
  }
  
  /// LIBROS ORDENADOS
  Stream<List<Book>> getBooksStream() {
    return _firestore.collection('books').orderBy('titulo', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Book(
          id: doc.id,
          titulo: data['titulo'] ?? '',
          autor: data['autor'] ?? '',
          subtitulo: data['subtitulo'] ?? '',
          editorial: data['editorial'] ?? '',
          coleccion: data['coleccion'] ?? '',
          anio: data['anio'] ?? 0,
          isbn: data['isbn'] ?? '',
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

  ///Historial
  Stream<List<Historial>> getHistorialPorLibro(String idLibro) {
  return _firestore
      .collection('historial')
      .where('uid', isEqualTo: idLibro)
      .orderBy('fechaEdicion', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            return Historial.fromMap(doc.data());
          }).toList());
}
}