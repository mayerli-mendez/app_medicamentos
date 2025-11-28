import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // 1) Inicializar timezones
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Guayaquil'));

    // 2) Inicialización 
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
    );

    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // 4) Crear canal con vibración y luces
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicamentos_channel', 
      'Recordatorios de medicamentos', 
      description: 'Notificaciones para la toma de medicamentos',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
    );

    await androidPlugin?.createNotificationChannel(channel);

    _initialized = true;
  }


  Future<void> mostrarNotificacionPrueba() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicamentos_channel',
      'Recordatorios de medicamentos',
      channelDescription: 'Notificaciones para la toma de medicamentos',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      color: Colors.green,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      999, // id cualquiera
      'Prueba de notificación',
      'Si ves esto en tu celu, las notificaciones están OK.',
      notificationDetails,
    );
  }

  /// Programar recordatorio para un medicamento usando un delay simple.
  /// (Funciona mientras la app siga viva en segundo plano)
  Future<void> programarRecordatorioMedicamento({
    required int idNotificacion,
    required String nombreMedicamento,
    required String horarioHHmm, // ej: "13:45"
    required String color,
    required bool vibracion,
  }) async {
    // Parsear HH:mm
    final partes = horarioHHmm.split(':');
    final int hora = int.parse(partes[0]);
    final int minuto = int.parse(partes[1]);

    final ahora = DateTime.now();
    var programado = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      hora,
      minuto,
    );

    // Si la hora ya pasó hoy, se programa para mañana
    if (programado.isBefore(ahora)) {
      programado = programado.add(const Duration(days: 1));
    }

    final duration = programado.difference(ahora);

    final androidDetails = AndroidNotificationDetails(
      'medicamentos_channel',
      'Recordatorios de medicamentos',
      channelDescription: 'Notificaciones para la toma de medicamentos',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: vibracion,
      playSound: true,
      color: _colorFromNombre(color),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Usamos Future.delayed en vez de zonedSchedule para evitar errores del plugin
    Future.delayed(duration, () async {
      await _flutterLocalNotificationsPlugin.show(
        idNotificacion,
        'Toma tu medicamento',
        '$nombreMedicamento a las $horarioHHmm',
        notificationDetails,
      );
    });
  }

  Color _colorFromNombre(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'rojo':
        return Colors.red;
      case 'verde':
        return Colors.green;
      case 'azul':
        return Colors.blue;
      case 'amarillo':
        return Colors.yellow;
      default:
        return Colors.teal;
    }
  }
}
