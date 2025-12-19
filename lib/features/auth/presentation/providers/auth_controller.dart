import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/auth_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final local = ref.read(authLocalDataSourceProvider);
    final user = local.getUser();

    if (user == null) {
      return null;
    }

    final repo = ref.read(authRepositoryProvider);

    try {
      await repo.isTokenValid(user.token!);
      return user;
    } catch (error) {
      final errorDio = error as DioException;
      if (errorDio.response?.statusCode == 401) {
        local.removeUser();
        return null;
      }
      return null;
    }
  }

  Future<void> login(String username, String password) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return repository.login(username, password);
    });
  }

  void logout() {
    ref.read(authLocalDataSourceProvider).removeUser();
    state = const AsyncValue.data(null);
  }
}
