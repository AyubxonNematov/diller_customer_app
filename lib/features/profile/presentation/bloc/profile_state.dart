part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user, {this.refreshedAt});
  final Map<String, dynamic> user;
  final int? refreshedAt;

  @override
  List<Object?> get props => [user, refreshedAt];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}
