class Sale {
  final int? id;
  final String titulo;
  final String autor;
  final int cantidad;
  final double precioUnitario;
  final double total;
  final String lugarVenta;
  final DateTime fechaVenta;
  final String usuarioVenta;

  Sale({
    this.id,
    required this.titulo,
    required this.autor,
    required this.cantidad,
    required this.precioUnitario,
    required this.total,
    required this.lugarVenta,
    required this.fechaVenta,
    required this.usuarioVenta,
  });

  Sale copyWith({
    int? id,
    String? titulo,
    String? autor,
    int? cantidad,
    double? precioUnitario,
    double? total,
    String? lugarVenta,
    DateTime? fechaVenta,
    String? usuarioVenta,
  }) {
    return Sale(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      total: total ?? this.total,
      lugarVenta: lugarVenta ?? this.lugarVenta,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      usuarioVenta: usuarioVenta ?? this.usuarioVenta,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'total': total,
      'lugar_venta': lugarVenta,
      'fecha_venta': fechaVenta.toIso8601String(),
      'usuario_venta': usuarioVenta,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id']?.toInt(),
      titulo: map['titulo'] ?? '',
      autor: map['autor'] ?? '',
      cantidad: map['cantidad']?.toInt() ?? 0,
      precioUnitario: map['precio_unitario']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      lugarVenta: map['lugar_venta'] ?? '',
      fechaVenta: DateTime.parse(map['fecha_venta']),
      usuarioVenta: map['usuario_venta'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, titulo: $titulo, autor: $autor, cantidad: $cantidad, precioUnitario: $precioUnitario, total: $total, lugarVenta: $lugarVenta, fechaVenta: $fechaVenta, usuarioVenta: $usuarioVenta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sale &&
        other.id == id &&
        other.titulo == titulo &&
        other.autor == autor &&
        other.cantidad == cantidad &&
        other.precioUnitario == precioUnitario &&
        other.total == total &&
        other.lugarVenta == lugarVenta &&
        other.fechaVenta == fechaVenta &&
        other.usuarioVenta == usuarioVenta;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        titulo.hashCode ^
        autor.hashCode ^
        cantidad.hashCode ^
        precioUnitario.hashCode ^
        total.hashCode ^
        lugarVenta.hashCode ^
        fechaVenta.hashCode ^
        usuarioVenta.hashCode;
  }
}