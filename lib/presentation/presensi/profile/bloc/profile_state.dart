part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final DataUser profile ;

  ProfileLoaded({required this.profile});
}

final class ProfileUpdateSuccess extends ProfileState {
  final String message;

  ProfileUpdateSuccess({required this.message});
}

final class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure({required this.error});
}