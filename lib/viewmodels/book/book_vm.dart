//=========================== IMPORTACIONES PRINCIPALES ===========================//
// ESTAS IMPORTACIONES PERMITEN MANEJAR ARCHIVOS, UI, FIREBASE, SUPABASE Y DATOS
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diacritic/diacritic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/global/dialog.dart';
import '../../models/book_m.dart';
import '../../models/history_bk.dart';


//=========================== LIMPIADOR DE NOMBRES DE ARCHIVO ===========================//
// ESTA FUNCIÓN ASEGURA QUE LOS ARCHIVOS SUBIDOS TENGAN NOMBRES SEGUROS
String safeFileName(String original) {
  // QUITAR ACENTOS DEL NOMBRE ORIGINAL
  String name = removeDiacritics(original);
  // REEMPLAZAR ESPACIOS POR GUIONES BAJOS
  name = name.replaceAll(RegExp(r'\s+'), '_');
  // ELIMINAR CARACTERES NO PERMITIDOS
  name = name.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '');
  return name;
}


class BookViewModel {
  //=========================== INSTANCIAS DE FIRESTORE Y SUPABASE ===========================//
  // SE DECLARAN CLIENTES COMPARTIDOS PARA OPERACIONES EN LA NUBE
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;


  //=========================== MOSTRAR DIALOGOS / TOASTS ===========================//
  // ESTA FUNCIÓN CENTRALIZA LA VISUALIZACIÓN DE NOTIFICACIONES PERSONALIZADAS
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
        // AUTO-CIERRE OPCIONAL DEL MENSAJE
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


  //=========================== GENERADOR DE ID TEMPORAL ===========================//
  // ESTA FUNCIÓN CREA UN ID ÚNICO PARA DETECTAR REGISTROS DUPLICADOS
  String generarIdTemporal(Book book) {
    final titulo = removeDiacritics(book.titulo.trim().toLowerCase());
    final autor = removeDiacritics(book.autor.trim().toLowerCase());
    final anio = book.anio.toString();
    final base = '$titulo$autor$anio';

    return base
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }


  //=========================== AGREGAR LIBRO ===========================//
  // AGREGA UN NUEVO LIBRO A FIRESTORE SOLO SI NO EXISTE UN DUPLICADO
  Future<void> addBook(Book book, BuildContext context) async {
    try {
      // GENERAR ID ÚNICO PARA VALIDAR DUPLICADOS
      final tempId = generarIdTemporal(book);

      final existing = await _firestore
          .collection('books')
          .where('idTemp', isEqualTo: tempId)
          .get();

      // VALIDAR DUPLICADOS
      if (existing.docs.isNotEmpty) {
        if (context.mounted) {
          _mostrarDialogo(
            context,
            title: 'REGISTRO DUPLICADO',
            message: 'YA EXISTE UN LIBRO CON ESE TÍTULO, AUTOR Y AÑO.',
            color: Colors.orangeAccent,
            icon: Icons.warning_amber_rounded,
            autoCerrar: false,
          );
        }
        return;
      }

      //=========================== SUBIR IMAGEN A SUPABASE ===========================//
      // SI EL LIBRO INCLUYE UNA IMAGEN, AQUÍ SE PROCESA LA CARGA
      String? uploadedUrl = book.imagenUrl;

      if (book.imagenFile != null) {
        try {
          // GENERAR NOMBRE SEGURO DE ARCHIVO
          final originalName = book.imagenFile!.path.split(RegExp(r'[\\/]+')).last;
          final safeName = safeFileName(originalName);
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

          // SUBIR ARCHIVO A SUPABASE
          await supabase.storage.from('book_images').upload(
                fileName,
                File(book.imagenFile!.path),
              );

          uploadedUrl = supabase.storage.from('book_images').getPublicUrl(fileName);
        } catch (e) {
          debugPrint("ERROR SUBIENDO IMAGEN A SUPABASE: $e");
        }
      }

      // CAPTURA DE USUARIO QUE REGISTRA EL LIBRO
      final user = FirebaseAuth.instance.currentUser;
      final registrador = user?.email ?? 'desconocido';
      final fecha = DateTime.now();

      // CALCULAR ESTADO (SOLO DISPONIBLE SI TIENE 3+ COPIAS)
      final bool estado = (book.copias >= 3);

      // CREAR DOCUMENTO NUEVO EN FIRESTORE
      final docRef = _firestore.collection('books').doc();

      final bookToSave = book.copyWith(
        id: docRef.id,
        imagenUrl: uploadedUrl,
        fechaRegistro: fecha,
        estado: estado,
      );

      // GUARDAR DATOS COMPLETOS EN FIRESTORE
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
          title: '¡REGISTRO EXITOSO!',
          message: 'EL LIBRO SE HA GUARDADO CORRECTAMENTE.',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR AL SUBIR IMAGEN O GUARDAR LIBRO: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            _mostrarDialogo(
              context,
              title: 'ERROR',
              message: 'NO SE PUDO REGISTRAR EL LIBRO. INTENTA NUEVAMENTE.',
              color: Colors.redAccent,
              icon: Icons.error_outline,
            );
          }
        });
      }
    }
  }


  //=========================== EDITAR LIBRO EXISTENTE ===========================//
  // PERMITE MODIFICAR DATOS DE UN LIBRO Y REGISTRAR HISTORIAL DE CAMBIOS
  Future<void> editBook(Book book, BuildContext context) async {
    try {
      if (book.id == null) throw Exception("EL LIBRO NO TIENE ID PARA EDITAR.");

      // SUBIR NUEVA IMAGEN SI SE MODIFICÓ
      String? uploadedUrl = book.imagenUrl;

      if (book.imagenFile != null) {
        try {
          final originalName = book.imagenFile!.path.split(RegExp(r'[\\/]+')).last;
          final safeName = safeFileName(originalName);
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

          await supabase.storage.from('book_images').upload(
                fileName,
                File(book.imagenFile!.path),
              );

          uploadedUrl = supabase.storage.from('book_images').getPublicUrl(fileName);
        } catch (e) {
          debugPrint("ERROR SUBIENDO IMAGEN A SUPABASE: $e");
        }
      }

      // RECALCULAR ESTADO DEL LIBRO
      final bool estado = (book.copias >= 3);

      final updatedBook = book.copyWith(
        imagenUrl: uploadedUrl,
        estado: estado,
      );

      final nuevo = updatedBook.toMap();

      // OBTENER DATOS ANTERIORES PARA DETECTAR CAMBIOS
      final docSnapshot = await _firestore.collection('books').doc(book.id).get();
      final datosAnteriores = docSnapshot.data();

      final cambios = <String, dynamic>{};

      // COMPARAR CAMPO POR CAMPO
      datosAnteriores?.forEach((key, valorAnterior) {
        final valorNuevo = nuevo[key];
        if (valorNuevo != null && valorNuevo != valorAnterior) {
          cambios[key] = '$valorAnterior → $valorNuevo';
        }
      });

      // REGISTRAR CAMBIOS EN HISTORIAL
      if (cambios.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        final editor = user?.email ?? 'desconocido';

        await _firestore.collection('history').add({
          'idBook': book.id,
          'editadoPor': editor,
          'fechaEdicion': FieldValue.serverTimestamp(),
          'cambios': cambios,
          'accion': 'Modificado',
        });
      }

      // ACTUALIZAR LIBRO EN FIRESTORE
      await _firestore.collection('books').doc(book.id).update(updatedBook.toMap());

      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _mostrarDialogo(
            context,
            title: '¡EDICIÓN EXITOSA!',
            message: 'EL LIBRO SE HA ACTUALIZADO CORRECTAMENTE.',
            color: Colors.green,
            icon: Icons.check_circle_outline,
          );
        });
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR AL EDITAR LIBRO: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (context.mounted) {
        _mostrarDialogo(
          context,
          title: 'ERROR',
          message: 'NO SE PUDO ACTUALIZAR EL LIBRO.',
          color: Colors.redAccent,
          icon: Icons.error_outline,
        );
      }
    }
  }


  //=========================== ELIMINAR LIBRO ===========================//
  // PERMITE BORRAR UN LIBRO DEFINITIVAMENTE DE FIRESTORE
  Future<void> deleteBook(String id) async {
    try {
      await _firestore.collection('books').doc(id).delete();
    } catch (e) {
      debugPrint("ERROR ELIMINANDO LIBRO: $e");
    }
  }


  //=========================== STREAM DE LIBROS ACTIVOS ===========================//
  // DEVUELVE LOS LIBROS DISPONIBLES (ESTADO == TRUE) EN TIEMPO REAL
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


  //=========================== STREAM DE HISTORIAL ===========================//
  // DEVUELVE EL HISTORIAL DE CAMBIOS DE CADA LIBRO
  Stream<List<Historial>> getHistorialPorLibro(String idLibro) {
    return _firestore
        .collection('history')
        .where('idBook', isEqualTo: idLibro)
        .orderBy('fechaEdicion', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Historial.fromMap(doc.data())).toList());
  }


  //=========================== CACHE LOCAL Y EXPORTACIÓN ===========================//

  // LISTA LOCAL QUE ALMACENA LIBROS ACTIVOS
  List<Book> _cachedBooks = [];

  // DEVUELVE CUÁNTOS LIBROS ACTIVOS HAY EN CACHÉ
  int get booksCount => _cachedBooks.length;

  // REFRESCA LA CACHÉ CONSULTANDO FIRESTORE
  Future<void> refreshCache() async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .where('estado', isEqualTo: true)
          .orderBy('titulo', descending: false)
          .get();

      _cachedBooks = snapshot.docs.map((doc) {
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
          imagenUrl: data['imagenUrl'] ?? 'assets/sinportada.png',
          estado: data['estado'] ?? true,
          fechaRegistro: (data['fechaRegistro'] is Timestamp)
              ? (data['fechaRegistro'] as Timestamp).toDate()
              : DateTime.now(),
          estante: data['estante'] ?? 0,
          almacen: data['almacen'] ?? 0,
          areaConocimiento: data['areaConocimiento'] ?? '',
          registradoPor: data['registradoPor'] ?? 'desconocido',
        );
      }).toList();
    } catch (e, s) {
      debugPrint("ERROR AL REFRESCAR CACHÉ DE LIBROS: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  // CONVIERTE TODOS LOS LIBROS ACTIVOS A UNA LISTA DE MAPAS PARA EXPORTAR
  Future<List<Map<String, dynamic>>> getAllBooksAsMap() async {
    if (_cachedBooks.isEmpty) await refreshCache();

    final activos = _cachedBooks.where((b) => b.estado == true).toList();
    return activos.map((book) => _bookToMap(book)).toList();
  }

  // CONVIERTE SOLO LOS LIBROS SELECCIONADOS A FORMATO EXPORTABLE
  Future<List<Map<String, dynamic>>> getSelectedBooksAsMap(
    List<Book> selectedBooks,
  ) async {
    if (selectedBooks.isEmpty) return [];

    final activos = selectedBooks.where((b) => b.estado == true).toList();
    return activos.map((b) => _bookToMap(b)).toList();
  }

  // MAPEA UN LIBRO A CAMPOS SEGUROS PARA EXCEL
  Map<String, dynamic> _bookToMap(Book book) {
    return {
      'Título': book.titulo,
      'Subtítulo': book.subtitulo,
      'Autor': book.autor,
      'Editorial': book.editorial,
      'Colección': book.coleccion,
      'Año': book.anio,
      'ISBN': book.isbn,
      'Copias': book.copias,
      'Área de conocimiento': book.areaConocimiento,
    };
  }
}
