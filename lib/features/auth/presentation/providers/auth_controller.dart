import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';

// 1. PROVIDER: Espone il controller alla UI
// AsyncNotifierProvider<ClasseController, TipoDiStato>
final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

// 2. CONTROLLER: Gestisce la logica
class AuthController extends AsyncNotifier<User?> {

  @override
  FutureOr<User?> build() {
    // Stato iniziale: null (nessun utente loggato)
    return null;
  }

  // Metodo chiamato dal bottone Login
  Future<void> login(String username, String password) async {
    // 1. Mettiamo lo stato in "Loading"
    // (state è una variabile magica di Riverpod che contiene il dato corrente)
    state = const AsyncValue.loading();

    // 2. Usiamo AsyncValue.guard
    // È un trucco bellissimo: prova a eseguire la funzione.
    // Se riesce, mette il risultato in state (Data).
    // Se fallisce, mette l'eccezione in state (Error).
    state = await AsyncValue.guard(() async {
      // Leggiamo il repository usando "ref" (che qui dentro è disponibile)
      final repository = ref.read(authRepositoryProvider);
      return repository.login(username, password);
    });
  }

  // Metodo per il logout (opzionale per ora)
  void logout() {
    state = const AsyncValue.data(null);
  }
}