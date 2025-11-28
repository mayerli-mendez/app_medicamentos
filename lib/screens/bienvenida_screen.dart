import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen LOGO.png
              SizedBox(
                height: 220,
                child: Image.asset(
                  'lib/images/LOGO.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Bienvenido a RecordMed',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w700, // Bold
                ),
              ),

              const SizedBox(height: 8),

              
              Text(
                'Porque recordar tus medicamentos no debería ser difícil.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 40),

              // Botones
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('INICIAR SESIÓN'),
                ),
              ),

              const SizedBox(height: 12),

             // Botón outlined
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/registro'),
                  child: const Text('REGISTRARSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
