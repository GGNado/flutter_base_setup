import 'package:dio/dio.dart';
import 'package:flutter_base_setup/features/user/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.read(dioProvider)),
);

class UserRepositoryImpl implements UserRepository {
  final Dio _dio;

  UserRepositoryImpl(this._dio);

  @override
  Future<List<UserResponse>> getUsers() async {
    final response = await _dio.get('/api/utenti');
    final rawList = response.data["utenteFindAllDTO"] as List<dynamic>? ?? [];

    return rawList
        .map((json) => UserResponseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
