import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_setup/core/widgets/app_text_field.dart';
import 'package:flutter_base_setup/features/auth/presentation/widget/login_button.dart';
import 'package:flutter_base_setup/features/auth/presentation/widget/register_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void onPressed() {
    FocusScope.of(context).unfocus();
    ref
        .read(authControllerProvider.notifier)
        .login(_usernameController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final hasError = authState.hasError;
    int? typeError;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.value != null && (previous?.value == null)) {
        context.go("/home");
      }
    });

    if (hasError) {
      DioException error = authState.error as DioException;
      if (error.response == null &&
          (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout)) {
        typeError = 61;
      } else {
        typeError = error.response?.statusCode;
      }
    }

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColor.withValues(alpha: 0.6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 76,
                        backgroundImage: NetworkImage(
                          "https://cdn-icons-png.flaticon.com/512/6325/6325109.png",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  if (hasError) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (typeError == 401) ...[
                            const Icon(Icons.block, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              "Credenziali non valide",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else if (typeError == 61) ...[
                            const Icon(Icons.wifi, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              "Errore di connessione",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Column(
                    children: [
                      AppTextField(
                        controller: _usernameController,
                        label: "Username",
                        icon: Icons.person,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        primaryColor: primaryColor,
                        isPassword: true,
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoginButton(
                            isLoading: isLoading,
                            primaryColor: primaryColor,
                            onPressed: onPressed,
                          ),
                          const SizedBox(width: 16),
                          RegisterButton(onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
