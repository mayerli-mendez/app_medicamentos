import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/medicamento.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart'; 

class MedicamentoFormScreen extends StatefulWidget {
  final Usuario usuario;
  final Medicamento? medicamento; 

  const MedicamentoFormScreen({
    super.key,
    required this.usuario,
    this.medicamento,
  });

  @override
  State<MedicamentoFormScreen> createState() => _MedicamentoFormScreenState();
}

class _MedicamentoFormScreenState extends State<MedicamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  TimeOfDay _hora = const TimeOfDay(hour: 8, minute: 0);
  String _colorSeleccionado = 'rojo';
  bool _vibracion = true;
  bool _cargando = false;
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.medicamento != null) {
      final m = widget.medicamento!;
      _nombreCtrl.text = m.nombre;
      _dosisCtrl.text = m.dosis;

      final partes = m.horario.split(':');
      if (partes.length == 2) {
        _hora = TimeOfDay(
          hour: int.tryParse(partes[0]) ?? 8,
          minute: int.tryParse(partes[1]) ?? 0,
        );
      }

      _colorSeleccionado = m.color;
      _vibracion = m.vibracion;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _dosisCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora() async {
    final nuevaHora =
        await showTimePicker(context: context, initialTime: _hora);
    if (nuevaHora != null) {
      setState(() => _hora = nuevaHora);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final horario =
        '${_hora.hour.toString().padLeft(2, '0')}:${_hora.minute.toString().padLeft(2, '0')}';

    bool ok;

    final int idNotificacion = widget.medicamento?.id ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (widget.medicamento == null) {
      // crear
      ok = await api.insertarMedicamento(
        usuarioId: widget.usuario.id,
        nombre: _nombreCtrl.text,
        dosis: _dosisCtrl.text,
        horario: horario,
        color: _colorSeleccionado,
        vibracion: _vibracion,
      );
    } else {
      // editar
      ok = await api.actualizarMedicamento(
        id: widget.medicamento!.id,
        nombre: _nombreCtrl.text,
        dosis: _dosisCtrl.text,
        horario: horario,
        color: _colorSeleccionado,
        vibracion: _vibracion,
      );
    }

    setState(() => _cargando = false);

    if (ok) {
      
      await NotificationService().programarRecordatorioMedicamento(
        idNotificacion: idNotificacion,
        nombreMedicamento: _nombreCtrl.text,
        horarioHHmm: horario,             
        color: _colorSeleccionado,      
        vibracion: _vibracion,         
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar')),
      );
    }
  }

  Widget _buildColorChip(String nombre, Color color) {
    final seleccionado = _colorSeleccionado == nombre;
    return GestureDetector(
      onTap: () => setState(() => _colorSeleccionado = nombre),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          nombre,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.medicamento != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar medicamento' : 'Agregar medicamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese el nombre' : null,
              ),
              TextFormField(
                controller: _dosisCtrl,
                decoration: const InputDecoration(labelText: 'Dosis (mg)'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese la dosis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Horario: '),
                  Text(_hora.format(context)),
                  TextButton(
                    onPressed: _seleccionarHora,
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Color del medicamento:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildColorChip('rojo', Colors.red),
                    _buildColorChip('verde', Colors.green),
                    _buildColorChip('azul', Colors.blue),
                    _buildColorChip('amarillo', Colors.yellow),
                    _buildColorChip('morado', Colors.purple),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activar vibración'),
                value: _vibracion,
                onChanged: (v) => setState(() => _vibracion = v),
              ),
              const SizedBox(height: 24),
              _cargando
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
