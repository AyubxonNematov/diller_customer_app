import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/utils/api_error.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileLoading()) {
    on<ProfileLoad>(_onLoad);
    on<ProfileRefresh>(_onRefresh);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoad(ProfileLoad event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    ProfileRefresh event,
    Emitter<ProfileState> emit,
  ) async {
    await _fetch(emit);
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    emit(const ProfileLoggedOut());
  }

  Future<void> _fetch(Emitter<ProfileState> emit) async {
    try {
      final api = getIt<ApiClient>();
      final r = await api.dio.get('/me');
      final user = r.data as Map<String, dynamic>;
      emit(ProfileLoaded(user, refreshedAt: DateTime.now().millisecondsSinceEpoch));
    } catch (e) {
      emit(ProfileError(parseApiError(e)));
    }
  }

  /// ProfileRefresh event qo'shib, natija kutiladi. RefreshIndicator uchun.
  Future<void> refresh() async {
    final completer = Completer<void>();
    final sub = stream
        .where((s) => s is ProfileLoaded || s is ProfileError)
        .listen((_) => completer.complete(), cancelOnError: true);
    add(const ProfileRefresh());
    try {
      await completer.future.timeout(const Duration(seconds: 30));
    } finally {
      await sub.cancel();
    }
  }
}
