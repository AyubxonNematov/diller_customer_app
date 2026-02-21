part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AuthSendCode extends AuthEvent {
  AuthSendCode(this.phone);
  final String phone;
}

final class AuthVerify extends AuthEvent {
  AuthVerify({required this.phone, required this.code, this.name});
  final String phone;
  final String code;
  final String? name;
}

final class AuthLogout extends AuthEvent {}
