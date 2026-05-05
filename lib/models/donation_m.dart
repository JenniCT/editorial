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
  final int deEstante;
  final int deAlmacen;
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
    this.deEstante = 0,
    this.deAlmacen = 0,
    this.selected  = false,
  });

  Donation copyWith({
    String? id,
    String? bookId,
    String? titulo,
    String? autor,
    int? cantidad,
    DateTime? fecha,
    String? userId,
    String? userEmail,
    String? lugar,
    String? nota,
    int? deEstante,
    int? deAlmacen,
    bool? selected,
  }) {
    return Donation(
      id:        id        ?? this.id,
      bookId:    bookId    ?? this.bookId,
      titulo:    titulo    ?? this.titulo,
      autor:     autor     ?? this.autor,
      cantidad:  cantidad  ?? this.cantidad,
      fecha:     fecha     ?? this.fecha,
      userId:    userId    ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      lugar:     lugar     ?? this.lugar,
      nota:      nota      ?? this.nota,
      deEstante: deEstante ?? this.deEstante,
      deAlmacen: deAlmacen ?? this.deAlmacen,
      selected:  selected  ?? this.selected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId':    bookId,
      'titulo':    titulo,
      'autor':     autor,
      'cantidad':  cantidad,
      'fecha':     fecha.toIso8601String(),
      'userId':    userId,
      'userEmail': userEmail,
      'lugar':     lugar,
      'nota':      nota,
      'deEstante': deEstante,
      'deAlmacen': deAlmacen,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Donation(
      id:        id,
      bookId:    map['bookId']    ?? '',
      titulo:    map['titulo']    ?? '',
      autor:     map['autor']     ?? '',
      cantidad:  (map['cantidad'] ?? 0) as int,
      fecha:     map['fecha'] != null
          ? DateTime.parse(map['fecha'])
          : DateTime.now(),
      userId:    map['userId']    ?? 'anonimo',
      userEmail: map['userEmail'] ?? 'anonimo',
      lugar:     map['lugar']     ?? '',
      nota:      map['nota'],
      deEstante: (map['deEstante'] ?? 0) as int,
      deAlmacen: (map['deAlmacen'] ?? 0) as int,
    );
  }
}