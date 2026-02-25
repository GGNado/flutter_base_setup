/* Questa è una classe astratta (un contratto).
La UI e i UseCases guarderanno SOLO questo file.
abstract class TUAEntitàRepository {
  Future<User> login(String username, String password);
  Future<bool> isTokenValid(String token);
}*/

import '../entities/user.dart';

abstract class UserRepository {
  Future<List<UserResponse>> getUsers();
}
