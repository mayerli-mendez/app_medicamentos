import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/notification_service.dart';
import 'screens/bienvenida_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/inicio_screen.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

 
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color botonColor = Color(0xFF189A91);

    return MaterialApp(
      title: 'App Medicamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: botonColor,
        ),
        useMaterial3: false,
        textTheme: TextTheme(
          // Títulos grandes → Poppins
          headlineMedium: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w700, // Bold
          ),
          // Texto normal → Roboto
          bodyMedium: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w900, // Black
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: botonColor,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w900, // Black
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: botonColor),
            foregroundColor: botonColor,
            textStyle: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const BienvenidaScreen(),
        '/login': (_) => const LoginScreen(),
        '/registro': (_) => const RegistroScreen(),
        '/inicio': (_) => const InicioScreen(),
      },
    );
  }
}
