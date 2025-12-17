import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasource/auth_local_data_source.dart';

final dioProvider = Provider<Dio>((ref) {

  final options = BaseOptions(
    baseUrl: 'http://localhost:8080',
    //baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {

      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final authLocalDataSource = ref.read(authLocalDataSourceProvider);

      final token = authLocalDataSource.getUser()?.token;

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    },
  ));
  return dio;
});