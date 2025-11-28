import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/medicamento.dart';

class ApiService {
  //final String baseUrl = "http://10.0.2.2/medicamentos_api/"; emulador
   final String baseUrl = "http://192.168.100.56/medicamentos_api/"; //celular
  // ---------- USUARIOS ----------

  Future<bool> registrarUsuario({
    required String nombre,
    required String apellido,
    required int edad,
    required String correo,
    required String contrasena,
  }) async {
    final response =
        await http.post(Uri.parse("${baseUrl}registrar_usuario.php"), body: {
      "nombre": nombre,
      "apellido": apellido,
      "edad": edad.toString(),
      "correo": correo,
      "contrasena": contrasena,
    });

    final data = jsonDecode(response.body);
    return data["estado"] == "ok";
  }

  Future<Usuario?> login({
    required String correo,
    required String contrasena,
  }) async {
    final response =
        await http.post(Uri.parse("${baseUrl}login.php"), body: {
      "correo": correo,
      "contrasena": contrasena,
    });

    final data = jsonDecode(response.body);

    if (data["estado"] == "ok") {
      return Usuario.fromJson({
        "id": data["id"],
        "nombre": data["nombre"],
        "correo": correo,
      });
    } else {
      return null;
    }
  }

  // ---------- MEDICAMENTOS ----------

  Future<List<Medicamento>> obtenerMedicamentos(int usuarioId) async {
    final response = await http.get(
      Uri.parse("${baseUrl}obtener_medicamentos.php?usuario_id=$usuarioId"),
    );

    final List<dynamic> lista = jsonDecode(response.body);
    return lista.map((e) => Medicamento.fromJson(e)).toList();
  }

  Future<bool> insertarMedicamento({
    required int usuarioId,
    required String nombre,
    required String dosis,
    required String horario,
    required String color,
    required bool vibracion,
  }) async {
    final response =
        await http.post(Uri.parse("${baseUrl}insertar_medicamento.php"), body: {
      "usuario_id": usuarioId.toString(),
      "nombre": nombre,
      "dosis": dosis,
      "horario": horario,
      "color": color,
      "vibracion": vibracion ? "1" : "0",
    });

    final data = jsonDecode(response.body);
    return data["estado"] == "ok";
  }

  Future<bool> actualizarMedicamento({
    required int id,
    required String nombre,
    required String dosis,
    required String horario,
    required String color,
    required bool vibracion,
  }) async {
    final response = await http.post(
      Uri.parse("${baseUrl}actualizar_medicamento.php"),
      body: {
        "id": id.toString(),
        "nombre": nombre,
        "dosis": dosis,
        "horario": horario,
        "color": color,
        "vibracion": vibracion ? "1" : "0",
      },
    );

    final data = jsonDecode(response.body);
    return data["estado"] == "ok";
  }

  Future<bool> eliminarMedicamento(int id) async {
    final response = await http.post(
      Uri.parse("${baseUrl}eliminar_medicamento.php"),
      body: {"id": id.toString()},
    );

    final data = jsonDecode(response.body);
    return data["estado"] == "ok";
  }
}
