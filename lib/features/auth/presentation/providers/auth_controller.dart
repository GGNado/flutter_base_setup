import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/auth_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

/// PROVIDER PRINCIPALE DI AUTENTICAZIONE
/// Gestisce lo stato dell'utente corrente (loggato o no).
///
/// Lo stato è un [AsyncValue<User?>]:
///   - AsyncData(User)  → Utente autenticato, token valido
///   - AsyncData(null)  → Nessun utente (nessun token o token invalido 401)
///   - AsyncLoading     → Stiamo verificando il token con il backend
///   - AsyncError       → Errore di rete/server → lo splash screen mostra "Riprova"
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // 1. Leggiamo i dati utente salvati localmente (SharedPreferences)
    final local = ref.read(authLocalDataSourceProvider);
    final user = local.getUser();

    // 2. Se non c'è nessun utente salvato → nessun token → vai al login
    if (user == null) {
      return null;
    }

    // 3. C'è un utente salvato → verifichiamo che il token sia ancora valido
    final repo = ref.read(authRepositoryProvider);

    try {
      await repo.isTokenValid(user.token);
      // Token valido! L'utente è autenticato.
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token scaduto o invalido → puliamo i dati locali e torniamo al login
        local.removeUser();
        return null;
      }
      // Errore di rete, timeout, server down → rilanciamo l'eccezione.
      // Questo fa passare lo stato a AsyncError, e lo Splash Screen
      // mostrerà il messaggio di errore con il bottone "Riprova".
      rethrow;
    }
  }

  /// Esegue il login con username e password.
  /// Lo stato passa a Loading → poi Data(User) o Error.
  Future<void> login(String username, String password) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return repository.login(username, password);
    });
  }

  /// Esegue il logout: pulisce i dati locali e resetta lo stato.
  void logout() {
    ref.read(authLocalDataSourceProvider).removeUser();
    state = const AsyncValue.data(null);
  }

  /// Riprova la verifica del token (chiamato dal bottone "Riprova" sullo splash).
  /// Invalida il provider, forzando una nuova esecuzione di build().
  void retry() {
    ref.invalidateSelf();
  }
}
