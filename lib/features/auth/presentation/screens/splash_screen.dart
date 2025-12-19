import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user.dart';
import '../providers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasStartedListening = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStartedListening) {
      _hasStartedListening = true;
      ref.listen<AsyncValue<User?>>(authControllerProvider, (_, next) {
        next.when(
          data: (user) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              if (user != null) {
                context.go('/home');
              } else {
                context.go('/login');
              }
            });
          },
          loading: () {},
          error: (_, __) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.go('/offline');
            });
          },
        );
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.rocket_launch_rounded, size: 100, color: Colors.white),
              SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
