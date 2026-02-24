import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

/// SPLASH SCREEN — Il primo schermo dell'app.
///
/// Flusso:
///   1. Si apre e mostra un loading spinner
///   2. [AuthController.build()] controlla se c'è un token salvato
///   3. Se il token è valido     → redirect a /home
///   4. Se non c'è token / 401   → redirect a /login
///   5. Se errore di rete         → mostra errore + bottone "Riprova"
///
/// NOTA RIVERPOD: Usiamo ref.listen() SOLO per i redirect (side-effects),
/// e ref.watch() per costruire la UI dello stato errore.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ─── SIDE-EFFECT: Navigazione ───
    // ref.listen è perfetto per side-effects come la navigazione.
    // NON si usa ref.watch per navigare: watch è per rebuild della UI.
    ref.listen(authControllerProvider, (previous, next) {
      // Evitiamo navigazione multipla: controlliamo che non siamo in loading
      if (next.isLoading) return;

      next.whenData((user) {
        // Aspettiamo il prossimo frame per navigare in sicurezza
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          if (user != null) {
            context.go('/home'); // Token valido → Dashboard
          } else {
            context.go('/login'); // Nessun token / token invalido → Login
          }
        });
      });
    });

    // ─── UI: Costruiamo la schermata ───
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Logo / Icona ───
              const Icon(
                Icons.rocket_launch_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Flutter Base Setup',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),

              // ─── Stato dinamico ───
              authState.when(
                // CASO 1: Loading → Spinner
                loading: () => const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Verifica in corso...',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),

                // CASO 2: Dati pronti → Non mostriamo nulla perché
                // ref.listen si occupa del redirect. Mostriamo lo spinner
                // così la UI non fa "flash" prima del cambio pagina.
                data: (_) => const CircularProgressIndicator(
                  color: Colors.white,
                ),

                // CASO 3: Errore → Messaggio + Bottone Riprova
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getErrorMessage(error),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Controlla la tua connessione e riprova',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // ref.read → dentro callback, MAI ref.watch!
                          ref
                              .read(authControllerProvider.notifier)
                              .retry();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'RIPROVA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Converte l'errore in un messaggio user-friendly.
  String _getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Il server non risponde.\nTempo di attesa scaduto.';
        case DioExceptionType.connectionError:
          return 'Impossibile connettersi al server.\nVerifica la connessione.';
        default:
          return 'Errore di comunicazione con il server.';
      }
    }
    return 'Si è verificato un errore imprevisto.';
  }
}
