import '../models/bookM.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addBook(Book book) async {
    try {
      String? uploadedUrl = book.imagenUrl;

      // Solo subir archivo si hay imagen local
      if (book.imagenFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = _storage.ref().child('book_images/$fileName');

        await ref.putFile(book.imagenFile!);
        uploadedUrl = await ref.getDownloadURL();
      }

      // Construimos nuevo libro con URL actualizada o la que ya tenga
      final bookToSave = book.copyWith(
        imagenUrl: uploadedUrl,
        fechaRegistro: DateTime.now(),
      );

      await _firestore.collection('books').add(bookToSave.toMap());
    } catch (e, stackTrace) {
      print('Error al subir imagen o guardar libro: $e');
      print(stackTrace);
    }
  }

  Stream<List<Book>> getBooksStream() {
    return FirebaseFirestore.instance
        .collection('books')
        .orderBy('fechaRegistro', descending: true)
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
              formato: data['formato'] ?? '',
              imagenUrl: data['imagenUrl'],
              estado: data['estado'] ?? true,
              fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }

}


