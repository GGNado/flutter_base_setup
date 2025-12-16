import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

// 1. PROVIDER: Questo è il pezzo che Riverpod userà per "iniettare" il repository.
// Notare che restituisce l'interfaccia (AuthRepository), non l'implementazione.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Leggiamo il Dio client configurato nel Core
  final dio = ref.read(dioProvider);
  return AuthRepositoryImpl(dio);
});

// 2. IMPLEMENTAZIONE: La classe concreta che fa il lavoro reale
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/signin',
        data: {'usernameOrEmail': username, 'password': password},
      );

      // Qui avviene la magia: JSON -> Model -> Entity
      // Dato che UserModel implementa User, possiamo ritornarlo direttamente.
      print('Ho ricevuto: ${response.data}');
      print('Converto: ${UserModel.fromJson(response.data)}');
      return UserModel.fromJson(response.data);

    } on DioException catch (e) {
      // Qui dovresti gestire gli errori (es. lanciare una tua eccezione custom)
      throw Exception(e.message ?? "Errore sconosciuto");
    }
  }
}