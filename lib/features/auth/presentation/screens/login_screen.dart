import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    // 1. WATCH: Ascoltiamo lo stato per disegnare la UI (es. mostrare spinner)
    final authState = ref.watch(authControllerProvider);

    // 2. LISTEN: Ascoltiamo gli eventi per azioni uniche (es. SnackBar, Navigazione)
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        // Mostra errore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Errore: ${next.error}'),
              backgroundColor: Colors.red
          ),
        );
      } else if (next.value != null) {
        // Login successo!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Benvenuto ${next.value!.email}!'),
              backgroundColor: Colors.green
          ),
        );
        // Qui metterai: context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Clean Arch Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // 3. LOGICA UI: Se sta caricando mostriamo la rotellina, altrimenti il bottone
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                // 4. READ: Chiamiamo l'azione SENZA ridisegnare
                ref.read(authControllerProvider.notifier).login(
                  _usernameController.text,
                  _passwordController.text,
                );
              },
              child: const Text("LOGIN"),
            ),
          ],
        ),
      ),
    );
  }
}