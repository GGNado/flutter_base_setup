import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_base_setup/features/home/presentation/screens/home_page.dart';
import '../providers/auth_controller.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _showRetryButton = false;
    });
    // Imposta il timer a 10 secondi
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showRetryButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Se stiamo ancora caricando (isLoading = true)
    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rocket_launch_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),

                // Se sono passati 10 secondi mostriamo il bottone Riprova
                if (_showRetryButton) ...[
                  const Text(
                    "Il caricamento sta impiegando più del previsto.\nControlla la connessione.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Resetta il timer e ricarica il provider
                      _startTimer();
                      ref.invalidate(authControllerProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Riprova"),
                  )
                ] else ...[
                  // Altrimenti mostriamo lo spinner classico
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Caricamento...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                ],
              ],
            ),
          ),
        ),
      );
    } else if (authState.value != null) {
      return const HomePage();
    } else {
      return const LoginScreen();
    }
  }
}
