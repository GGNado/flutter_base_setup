import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controller per i campi di testo
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    // 1. WATCH: Ascoltiamo il provider per sapere se sta caricando (isLoading).
    // Usiamo watch perché dobbiamo ridisegnare la UI (mostrare spinner o bottoni) quando lo stato cambia.
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // 2. LISTEN: Ascoltiamo gli eventi per reagire (Side Effects).
    // Usiamo listen per navigazione e snackbar perché NON vogliamo ridisegnare il widget, ma solo eseguire un'azione una tantum.
    ref.listen(authControllerProvider, (previous, next) {
      // GESTIONE ERRORI
      // Controlliamo se c'è un errore NUOVO.
      // Il check `previous?.error != next.error` evita di mostrare lo stesso errore più volte se il widget si ricostruisce.
      if (next is AsyncError &&
          (previous is! AsyncError || previous?.error != next.error)) {
        ScaffoldMessenger.of(
          context,
        ).clearSnackBars(); // Pulizia code precedenti
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // GESTIONE SUCCESSO
      // Se abbiamo un valore (User) e prima non l'avevamo (o eravamo null), significa che il login è riuscito.
      else if (next.value != null && (previous?.value == null)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        context.go("/home"); // Navigazione con GoRouter
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                enabled: !isLoading, // Disabilita input durante il caricamento
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                enabled: !isLoading,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 30),

              // LOGICA UI CONDIZIONALE
              // Se carica -> Spinner
              // Se fermo -> Bottone
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () {
                    FocusScope.of(context).unfocus(); // Chiude la tastiera

                    // 3. READ: Eseguiamo l'azione.
                    // Usiamo read sul .notifier per chiamare il metodo login.
                    ref
                        .read(authControllerProvider.notifier)
                        .login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                  },
                  label: const Text('Login'),
                  icon: const Icon(Icons.login),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
