part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileLoad extends ProfileEvent {
  const ProfileLoad();
}

final class ProfileRefresh extends ProfileEvent {
  const ProfileRefresh();
}

final class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}
