part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class GetProfileRequested extends ProfileEvent {}

final class UpdateProfileRequested extends ProfileEvent {
  final UserRequestModel requestModel;

  UpdateProfileRequested({required this.requestModel});
}