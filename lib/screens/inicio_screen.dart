import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/medicamento.dart';
import '../services/api_service.dart';
import 'medicamento_form_screen.dart';


class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late Usuario _usuario;
  late Future<List<Medicamento>> _futureMedicamentos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recuperar el usuario enviado desde el login
    _usuario = ModalRoute.of(context)!.settings.arguments as Usuario;

    // Cargar medicamentos desde la API
    _futureMedicamentos = ApiService().obtenerMedicamentos(_usuario.id);
    // Si en tu ApiService se llama distinto (getMedicamentos, etc.),
    // cambia el nombre del método aquí y en _recargarMedicamentos().
  }

  void _recargarMedicamentos() {
    setState(() {
      _futureMedicamentos = ApiService().obtenerMedicamentos(_usuario.id);
    });
  }

  Future<void> _eliminarMedicamento(Medicamento med) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar medicamento'),
        content: Text('¿Seguro que deseas eliminar "${med.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      
      await ApiService().eliminarMedicamento(med.id);

      _recargarMedicamentos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medicamento "${med.nombre}" eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Bienvenido, ${_usuario.nombre}'),
  actions: [
    
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: _recargarMedicamentos,
    ),

  ],
),

      body: FutureBuilder<List<Medicamento>>(
        future: _futureMedicamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ocurrió un error: ${snapshot.error}'),
            );
          }

          final medicamentos = snapshot.data ?? [];

          if (medicamentos.isEmpty) {
            return const Center(
              child: Text(
                'No tienes medicamentos registrados aún.\nPulsa el botón + para agregar uno.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: medicamentos.length,
            itemBuilder: (context, index) {
              final med = medicamentos[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(med.nombre),
                  subtitle: Text(
                    'Dosis: ${med.dosis}\n'
                    'Horario: ${med.horario}\n'
                    'Color: ${med.color} | Vibración: ${med.vibracion}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MedicamentoFormScreen(
                                usuario: _usuario,
                                medicamento: med, // editar
                              ),
                            ),
                          );
                          _recargarMedicamentos();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _eliminarMedicamento(med),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicamentoFormScreen(
                usuario: _usuario,
                medicamento: null, // nuevo
              ),
            ),
          );
          _recargarMedicamentos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}
