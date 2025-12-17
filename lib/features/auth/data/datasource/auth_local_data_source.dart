import 'dart:convert';

import 'package:flutter_base_setup/features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/src/shared_preferences_legacy.dart';

import '../../../../core/storage/shared_prefs_provider.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return AuthLocalDataSource(prefs);
});

class AuthLocalDataSource {
  final SharedPreferences _prefs;
  AuthLocalDataSource(this._prefs);

  void saveUser(UserModel user)  {
    final jsonString = jsonEncode(user.toJson());
    _prefs.setString('cached_user', jsonString);
  }

  UserModel? getUser() {
    final jsonString = _prefs.getString('cached_user');
    if (jsonString != null) {
      return UserModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  void removeUser() {
    _prefs.remove('cached_user');
  }
}