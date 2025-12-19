import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasource/auth_local_data_source.dart';

/// Questo provider fornisce un'istanza di Dio configurata per tutta l'app.
/// Essendo un semplice [Provider], crea l'oggetto una volta sola e lo mantiene vivo.
final dioProvider = Provider<Dio>((ref) {

  // 1. CONFIGURAZIONE BASE
  // Qui definiamo URL base, timeout e header comuni.
  final options = BaseOptions(
    baseUrl: 'http://localhost:8080', // Cambia con il tuo IP se sei su emulatore Android (es. 10.0.2.2)
    connectTimeout: const Duration(seconds: 10), // Tempo max per connettersi al server
    receiveTimeout: const Duration(seconds: 10), // Tempo max per ricevere i dati
    headers: {
      'Content-Type': 'application/json', // Diciamo al server che inviamo JSON
    },
  );

  final dio = Dio(options);

  // 2. INTERCEPTORS (Il "middleware" di Dio)
  // Gli interceptor permettono di eseguire codice PRIMA di ogni richiesta o DOPO ogni risposta.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // --- LOGICA DI AUTENTICAZIONE AUTOMATICA ---
      
      // Recuperiamo il datasource locale per leggere il token salvato.
      // Usiamo 'read' perché siamo dentro una callback, non nel build della UI.
      final authLocalDataSource = ref.read(authLocalDataSourceProvider);
      final token = authLocalDataSource.getUser()?.token;

      // Se abbiamo un token, lo appiccichiamo automaticamente all'header 'Authorization'.
      // Così non dobbiamo scriverlo manualmente in ogni chiamata API!
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Continua con la richiesta originale
      return handler.next(options);
    },
    // Qui potremmo aggiungere onError per gestire errori globali (es. 401 Logout forzato)
  ));

  return dio;
});
