import 'package:flutter_base_setup/features/user/data/repositories/user_repository_impl.dart';
import 'package:flutter_base_setup/features/user/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. DEFINIZIONE DEL PROVIDER
// La sintassi è AsyncNotifierProvider<ClasseNotifier, TipoDiStato>
// Qui il TipoDiStato è List<UserResponse>, non UserResponse singolo.
final userControllerProvider =
    AsyncNotifierProvider<UserController, List<UserResponse>>(() {
      return UserController();
    });

// 2. CLASSE NOTIFIER
class UserController extends AsyncNotifier<List<UserResponse>> {
  @override
  Future<List<UserResponse>> build() async {
    final repository = ref.read(userRepositoryProvider);

    // final result = await repository.fetchInitialData();
    // return result;

    // 3. SYNTAX ERROR: List<UserResponse>() è obsoleto. Si usa []

    return repository.getUsers();
  }

  void resetState() {
    state = const AsyncValue.data([]);
  }
}
