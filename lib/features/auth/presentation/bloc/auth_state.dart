part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthShowPhoneInput extends AuthState {
  const AuthShowPhoneInput();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthCodeSent extends AuthState {
  const AuthCodeSent({required this.phone});
  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class AuthNeedsRegistration extends AuthState {
  const AuthNeedsRegistration({required this.tempToken, required this.phone});
  final String tempToken;
  final String phone;

  @override
  List<Object?> get props => [tempToken, phone];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.token, required this.customer});
  final String token;
  final Map<String, dynamic> customer;

  @override
  List<Object?> get props => [token, customer];
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
