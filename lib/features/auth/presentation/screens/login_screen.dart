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
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError && (previous is! AsyncError || previous?.error != next.error)) {
         ScaffoldMessenger.of(context).clearSnackBars();
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.value != null && (previous?.value == null)) {
         ScaffoldMessenger.of(context).clearSnackBars();
         context.go("/home");
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
                enabled: !isLoading,
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

              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () {
                    FocusScope.of(context).unfocus();

                    ref.read(authControllerProvider.notifier).login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                  },
                  label: const Text('Login'),
                  icon: const Icon(Icons.login),
                )
            ],
          ),
        ),
      ),
    );
  }
}
