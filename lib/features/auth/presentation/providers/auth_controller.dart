import 'dart:async';
import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/shared_prefs_provider.dart';
import '../../data/datasource/auth_local_data_source.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<User?> {


  @override
  Future<User?> build() async {
    final authLocalDataSource = ref.read(authLocalDataSourceProvider);
    final user = authLocalDataSource.getUser();

    if (user != null) {
      final bool = _checkTokenValidity(user);
      return await bool ? user : null;
    }

    return null;
  }

  Future<void> login(String username, String password) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return repository.login(username, password);
    });
  }
  
  Future<bool> _checkTokenValidity(User user) async {
    final repository = ref.read(authRepositoryProvider);
    return repository.isTokenValid(user.token);
    
  }

  void logout() {
    state = const AsyncValue.data(null);
    final repo = ref.read(authLocalDataSourceProvider);
    repo.removeUser();

  }
}