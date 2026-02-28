part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthCodeSent extends AuthState {
  AuthCodeSent({required this.phone});
  final String phone;
}

final class AuthAuthenticated extends AuthState {
  AuthAuthenticated({required this.token, required this.customer});
  final String token;
  final Map<String, dynamic> customer;
}

final class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}
