// Implementación completa en Bloque 2.
import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.eco_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text('Bienvenido a EcoHabit',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.home),
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
