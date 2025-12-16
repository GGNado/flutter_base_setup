import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Definiamo il Provider. Tutta l'app userà "ref.read(dioProvider)" per avere il client.
final dioProvider = Provider<Dio>((ref) {

  // 2. Opzioni Base (Timeout, URL Base)
  final options = BaseOptions(
    baseUrl: 'http://localhost:8080', // Uso un'API pubblica di test per ora
    //baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);

  // 3. Aggiungiamo un Interceptor per il Logging (Debug)
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print("📡 REQUEST [${options.method}] => ${options.path}");
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print("RESPONSE [${response.statusCode}] => ${response.requestOptions.path}");
      return handler.next(response);
    },
    onError: (error, handler) {
      print("ERROR [${error.response?.statusCode}] => ${error.message}");
      return handler.next(error);
    },
  ));

  return dio;
});