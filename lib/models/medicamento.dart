class Medicamento {
  final int id;
  final int usuarioId;
  final String nombre;
  final String dosis;
  final String horario;
  final String color;
  final bool vibracion;

  Medicamento({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.dosis,
    required this.horario,
    required this.color,
    required this.vibracion,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: int.parse(json['id'].toString()),
      usuarioId: int.parse(json['usuario_id'].toString()),
      nombre: json['nombre'] ?? '',
      dosis: json['dosis'] ?? '',
      horario: json['horario'] ?? '',
      color: json['color'] ?? '',
      vibracion: json['vibracion'].toString() == '1',
    );
  }
}
