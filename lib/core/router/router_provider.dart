import 'package:flutter/material.dart';
import 'package:flutter_base_setup/features/home/presentation/screens/home_page.dart';
import 'package:flutter_base_setup/features/user/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/user/presentation/screens/user_detail.dart';
import '../widgets/scaffold_with_nav.dart';

// Chiave globale per il Navigator. Serve per azioni globali (es. mostrare dialoghi sopra tutto)
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// PROVIDER DEL ROUTER
/// Definisce l'albero di navigazione dell'app.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', // Parte dallo Splash Screen per controllare il token

    routes: [
      // --- SPLASH SCREEN (Check Iniziale) ---
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // --- ROTTA SEMPLICE (LOGIN) ---
      // Non ha la bottom navigation bar perché è fuori dalla ShellRoute
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // --- SHELL ROUTE (NAVBAR PERSISTENTE) ---
      // Questa struttura permette di mantenere la BottomNavigationBar fissa
      // mentre il contenuto della pagina cambia (preserva lo stato delle tab!)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // ScaffoldWithNavbar è il widget che contiene la BottomBar e il child corrente
          return ScaffoldWithNavbar(navigationShell: navigationShell);
        },
        branches: [
          // RAMO 1: HOME TAB
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                // path principale della tab
                builder: (context, state) => const HomePage(),
                // Rotte figlie: Vengono mostrate "sopra" o "dentro" la tab corrente
                // ma mantengono la navbar visibile (se vuoi nasconderla, servono accorgimenti extra)
                routes: [
                  GoRoute(
                    path: 'users/detail', // URL finale: /home/user/detail
                    builder: (context, state) {
                      // Recuperiamo i parametri passati con 'extra'
                      final user = state.extra as UserResponse;
                      return DetailPage(userResponse: user);
                    },
                  ),
                ],
              ),
            ],
          ),

          // RAMO 2: CERCA TAB
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text("Cerca"))),
              ),
            ],
          ),

          // RAMO 3: PROFILO TAB
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text("Profilo"))),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
