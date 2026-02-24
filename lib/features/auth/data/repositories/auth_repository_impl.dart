import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_data_source.dart';
import '../models/user_model.dart';

/// Provider che fornisce l'implementazione concreta del repository di autenticazione.
/// Viene iniettato nei controller tramite Riverpod.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return AuthRepositoryImpl(dio, localDataSource);
});

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._dio, this._localDataSource);

  @override
  Future<User> login(String username, String password) async {
    final response = await _dio.post(
      '/api/auth/signin',
      data: {'usernameOrEmail': username, 'password': password},
    );
    UserModel user = UserModel.fromJson(response.data);
    _localDataSource.saveUser(user);

    return user;
  }

  @override
  Future<bool> isTokenValid(String token) async {
    // Il token viene aggiunto automaticamente dall'interceptor in dio_provider.dart
    // Non serve passarlo manualmente qui — l'interceptor legge il token salvato
    // e lo aggiunge all'header Authorization di ogni richiesta.
    final response = await _dio.post('/api/auth/validate');
    return response.statusCode == 200;
  }
}
