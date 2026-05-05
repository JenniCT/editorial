class Sale {
  final String? id;
  final String bookId;
  final String titulo;
  final String autor;
  final int cantidad;
  final DateTime fecha;
  final String userId;
  final String userEmail;
  final String lugar;
  final double total;
  final double precioUnitario;
  final int deEstante;
  final int deAlmacen;
  bool selected;

  Sale({
    this.id,
    required this.bookId,
    required this.titulo,
    required this.autor,
    required this.cantidad,
    required this.fecha,
    required this.userId,
    required this.userEmail,
    required this.lugar,
    required this.total,
    this.precioUnitario = 0.0,
    this.deEstante      = 0,
    this.deAlmacen      = 0,
    this.selected       = false,
  });

  Sale copyWith({
    String? id,
    String? bookId,
    String? titulo,
    String? autor,
    int? cantidad,
    DateTime? fecha,
    String? userId,
    String? userEmail,
    String? lugar,
    double? total,
    double? precioUnitario,
    int? deEstante,
    int? deAlmacen,
    bool? selected,
  }) {
    return Sale(
      id:             id             ?? this.id,
      bookId:         bookId         ?? this.bookId,
      titulo:         titulo         ?? this.titulo,
      autor:          autor          ?? this.autor,
      cantidad:       cantidad       ?? this.cantidad,
      fecha:          fecha          ?? this.fecha,
      userId:         userId         ?? this.userId,
      userEmail:      userEmail      ?? this.userEmail,
      lugar:          lugar          ?? this.lugar,
      total:          total          ?? this.total,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      deEstante:      deEstante      ?? this.deEstante,
      deAlmacen:      deAlmacen      ?? this.deAlmacen,
      selected:       selected       ?? this.selected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId':         bookId,
      'titulo':         titulo,
      'autor':          autor,
      'cantidad':       cantidad,
      'fecha':          fecha.toIso8601String(),
      'userId':         userId,
      'userEmail':      userEmail,
      'lugar':          lugar,
      'total':          total,
      'precioUnitario': precioUnitario,
      'deEstante':      deEstante,
      'deAlmacen':      deAlmacen,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, {String? id}) {
    return Sale(
      id:             id,
      bookId:         map['bookId']          ?? '',
      titulo:         map['titulo']          ?? '',
      autor:          map['autor']           ?? '',
      cantidad:       (map['cantidad']       ?? 0) as int,
      fecha:          DateTime.parse(map['fecha']),
      userId:         map['userId']          ?? '',
      userEmail:      map['userEmail']       ?? '',
      lugar:          map['lugar']           ?? 'Desconocido',
      total:          (map['total']          ?? 0.0).toDouble(),
      precioUnitario: (map['precioUnitario'] ?? 0.0).toDouble(),
      deEstante:      (map['deEstante']      ?? 0) as int,
      deAlmacen:      (map['deAlmacen']      ?? 0) as int,
    );
  }
}