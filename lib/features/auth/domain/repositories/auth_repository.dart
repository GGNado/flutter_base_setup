import '../entities/user.dart';

// Questa è una classe astratta (un contratto).
// La UI e i UseCases guarderanno SOLO questo file.
abstract class AuthRepository {
  // Nota: Ritorna "User" (Entity), NON "UserModel" (DTO).
  Future<User> login(String username, String password);
}