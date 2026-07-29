import 'package:flutter/material.dart';
import '../../core/theme/fama_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// First screen shown to a logged-out user. Matches the Stitch design
/// system's warm-parchment background + fertile-green pill buttons.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Hero mark -- swap this Container for your Stitch-exported
              // hero illustration/logo asset once you drop it into assets/images.
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: FamaColors.primaryContainer.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, size: 72, color: FamaColors.primary),
              ),
              const SizedBox(height: 32),
              Text('FAMA', style: textTheme.headlineLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Connecting farmers, extension workers,\nand dealers across Uganda',
                style: textTheme.bodyLarge?.copyWith(color: FamaColors.onBackground.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
