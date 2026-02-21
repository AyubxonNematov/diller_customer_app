import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthSendCode>(_onSendCode);
    on<AuthVerify>(_onVerify);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onSendCode(AuthSendCode event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final api = getIt<ApiClient>();
      await api.dio.post('/auth/send-code', data: {'phone': event.phone});
      emit(AuthCodeSent(phone: event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerify(AuthVerify event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final api = getIt<ApiClient>();
      final r = await api.dio.post('/auth/verify', data: {
        'phone': event.phone,
        'code': event.code,
        if (event.name != null) 'name': event.name,
      });
      final token = r.data['token'] as String?;
      if (token == null) {
        emit(AuthError('Token olindi emas'));
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      emit(AuthAuthenticated(user: r.data['user']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    emit(AuthInitial());
  }
}
