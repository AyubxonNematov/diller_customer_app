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
    on<AuthRegister>(_onRegister);
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
      final data = r.data as Map<String, dynamic>;

      if (data['status'] == 'needs_registration') {
        emit(AuthNeedsRegistration(
          tempToken: data['temp_token'] as String,
          phone: phone,
        ));
        return;
      }

      await _saveAndEmitAuthenticated(data, emit);
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final api = getIt<ApiClient>();
      final r = await api.dio.post('/auth/register', data: {
        'temp_token': event.tempToken,
        'name': event.name,
        if (event.surname != null) 'surname': event.surname,
        if (event.address != null) 'address': event.address,
        if (event.leafRegionId != null) 'leaf_region_id': event.leafRegionId,
      });
      await _saveAndEmitAuthenticated(r.data as Map<String, dynamic>, emit);
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _saveAndEmitAuthenticated(
    Map<String, dynamic> data,
    Emitter<AuthState> emit,
  ) async {
    final token = data['token'] as String?;
    if (token == null) {
      emit(AuthError('Token olinmadi'));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    emit(AuthAuthenticated(
      token: token,
      customer: (data['customer'] as Map<String, dynamic>?) ?? {},
    ));
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    emit(AuthInitial());
  }

  String _parseError(dynamic e) => parseApiError(e);
}
