part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthNavigateToPhoneInput extends AuthEvent {
  const AuthNavigateToPhoneInput();
}

final class AuthNavigateBack extends AuthEvent {
  const AuthNavigateBack();
}

final class AuthSendCode extends AuthEvent {
  const AuthSendCode(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class AuthVerify extends AuthEvent {
  const AuthVerify({required this.phone, required this.code, this.name});
  final String phone;
  final String code;
  final String? name;

  @override
  List<Object?> get props => [phone, code, name];
}

final class AuthRegister extends AuthEvent {
  const AuthRegister({
    required this.tempToken,
    required this.name,
    this.surname,
    this.address,
    this.leafRegionId,
  });
  final String tempToken;
  final String name;
  final String? surname;
  final String? address;
  final int? leafRegionId;

  @override
  List<Object?> get props => [tempToken, name, surname, address, leafRegionId];
}

final class AuthLogout extends AuthEvent {
  const AuthLogout();
}
