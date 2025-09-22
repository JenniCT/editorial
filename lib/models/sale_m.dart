class Sale {
  final String? id;
  final String bookId;
  final String titulo;
  final String autor;
  final int cantidad;
  final double total;
  final DateTime fecha;
  final String userId;
  final String userEmail;
  final String lugar;

  Sale({
    this.id,
    required this.bookId,
    required this.titulo,
    required this.autor,
    required this.cantidad,
    required this.total,
    required this.fecha,
    required this.userId,
    required this.userEmail,
    required this.lugar,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'titulo': titulo,
      'autor': autor,
      'cantidad': cantidad,
      'total': total,
      'fecha': fecha.toIso8601String(),
      'userId': userId,
      'userEmail': userEmail,
      'lugar': lugar,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, {String? id}) {
    return Sale(
      id: id,
      bookId: map['bookId'],
      titulo: map['titulo'],
      autor: map['autor'],
      cantidad: map['cantidad'],
      total: map['total'],
      fecha: DateTime.parse(map['fecha']),
      userId: map['userId'],
      userEmail: map['userEmail'],
      lugar: map['lugar'] ?? 'Desconocido',
    );
  }
}
