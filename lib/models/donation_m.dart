// MODELO PARA DONACIONES
class Donation {
  final String? id;
  final String bookId;
  final String titulo;
  final String autor;
  final int cantidad;
  final DateTime fecha;
  final String userId;
  final String userEmail;
  final String lugar;
  final String? nota;
  bool selected;

  Donation({
    this.id,
    required this.bookId,
    required this.titulo,
    required this.autor,
    required this.cantidad,
    required this.fecha,
    required this.userId,
    required this.userEmail,
    required this.lugar,
    this.nota,
    this.selected = false,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'titulo': titulo,
      'autor': autor,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'userId': userId,
      'userEmail': userEmail,
      'lugar': lugar,
      'nota': nota,
    };
  }

  // Crear instancia desde Firestore
  factory Donation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Donation(
      id: id,
      bookId: map['bookId'] ?? '',
      titulo: map['titulo'] ?? '',
      autor: map['autor'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      fecha: map['fecha'] != null
          ? DateTime.parse(map['fecha'])
          : DateTime.now(),
      userId: map['userId'] ?? 'anonimo',
      userEmail: map['userEmail'] ?? 'anonimo',
      lugar: map['lugar'] ?? '',
      nota: map['nota'],
    );
  }
}
