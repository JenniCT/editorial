import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diacritic/diacritic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/global/dialog.dart';
import '../../models/book_m.dart';
import '../../models/history_bk.dart';

/// --- FUNCION PARA LIMPIAR NOMBRES DE ARCHIVOS ---
String safeFileName(String original) {
  // Quita acentos
  String name = removeDiacritics(original);
  // Reemplaza espacios por guiones bajos
  name = name.replaceAll(RegExp(r'\s+'), '_');
  // Reemplaza cualquier caracter inválido
  name = name.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '');
  return name;
}

class BookViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

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

  /// GENERA UN ID TEMPORAL PARA VERIFICAR DUPLICADOS
  String generarIdTemporal(Book book) {
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
      final tempId = generarIdTemporal(book);
      final existing = await _firestore
          .collection('books')
          .where('idTemp', isEqualTo: tempId)
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

      // SUBIR IMAGEN A SUPABASE SI EXISTE
      String? uploadedUrl = book.imagenUrl;
      if (book.imagenFile != null) {
        try {
          // Solo el nombre seguro del archivo
          final originalName = book.imagenFile!.path.split(RegExp(r'[\\/]+')).last;
          final safeName = safeFileName(originalName);
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

          await supabase.storage.from('book_images').upload(
                fileName,
                File(book.imagenFile!.path),
              );
          uploadedUrl = supabase.storage.from('book_images').getPublicUrl(fileName);
        } catch (e) {
          debugPrint("Error subiendo imagen a Supabase: $e");
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      final registrador = user?.email ?? 'desconocido';
      final fecha = DateTime.now();

      final bool estado = (book.copias >= 3);
      final docRef = _firestore.collection('books').doc();

      final bookToSave = book.copyWith(
        id: docRef.id,
        imagenUrl: uploadedUrl,
        fechaRegistro: fecha,
        estado: estado,
      );

      await docRef.set({
        ...bookToSave.toMap(),
        'idBook': docRef.id,
        'idTemp': tempId,
        'registradoPor': registrador,
        'fechaRegistro': fecha,
        'estado': estado,
      });

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
      debugPrint('Error al subir imagen o guardar libro: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (context.mounted) {
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

      // SUBIR IMAGEN A SUPABASE SI EXISTE
      String? uploadedUrl = book.imagenUrl;
      if (book.imagenFile != null) {
        try {
          // Solo el nombre seguro del archivo
          final originalName = book.imagenFile!.path.split(RegExp(r'[\\/]+')).last;
          final safeName = safeFileName(originalName);
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

          await supabase.storage.from('book_images').upload(
                fileName,
                File(book.imagenFile!.path),
              );
          uploadedUrl = supabase.storage.from('book_images').getPublicUrl(fileName);
        } catch (e) {
          debugPrint("Error subiendo imagen a Supabase: $e");
        }
      }


      final bool estado = (book.copias >= 3);

      final updatedBook = book.copyWith(
        imagenUrl: uploadedUrl,
        estado: estado,
      );

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
    
      // HISTORIAL CON CAMBIOS
      if (cambios.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        final editor = user?.email ?? 'desconocido';
        final fechaEdicion = DateTime.now();

        await _firestore.collection('history').add({
          'idBook': book.id,
          'editadoPor': editor,
          'fechaEdicion': fechaEdicion,
          'cambios': cambios,
          'accion' : 'Modificado',
        });
      }
      
      await _firestore.collection('books').doc(book.id).update(updatedBook.toMap());

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


  /// STREAM SOLO DE LIBROS DISPONIBLES (estado == true)
  Stream<List<Book>> getBooksStream() {
    return _firestore
        .collection('books')
        .where('estado', isEqualTo: true)
        .orderBy('titulo', descending: false)
        .snapshots()
        .map((snapshot) {
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

  /// HISTORIAL POR LIBRO
  Stream<List<Historial>> getHistorialPorLibro(String idLibro) {
    return _firestore
        .collection('history')
        .where('idBook', isEqualTo: idLibro)
        .orderBy('fechaEdicion', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Historial.fromMap(doc.data())).toList());
  }
}
