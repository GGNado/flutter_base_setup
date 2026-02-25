import 'package:flutter_base_setup/features/user/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserResponseModel with _$UserResponseModel implements UserResponse {
  const UserResponseModel._();

  const factory UserResponseModel({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
  }) = _UserResponseModel;

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserResponseModelFromJson(json);
}
