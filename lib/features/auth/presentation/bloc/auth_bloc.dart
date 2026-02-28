import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/utils/api_error.dart';

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
      final phone = event.phone.replaceAll(RegExp(r'\D'), '');
      await api.dio.post('/auth/send-code', data: {'phone': phone});
      emit(AuthCodeSent(phone: phone));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onVerify(AuthVerify event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final api = getIt<ApiClient>();
      final phone = event.phone.replaceAll(RegExp(r'\D'), '');
      final r = await api.dio.post('/auth/verify', data: {
        'phone': phone,
        'code': event.code,
      });
      final token = r.data['token'] as String?;
      if (token == null) {
        emit(AuthError('Token olinmadi'));
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      final customer = r.data['customer'] as Map<String, dynamic>?;
      emit(AuthAuthenticated(
        token: token,
        customer: customer ?? {},
      ));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    emit(AuthInitial());
  }

  String _parseError(dynamic e) => parseApiError(e);
}
