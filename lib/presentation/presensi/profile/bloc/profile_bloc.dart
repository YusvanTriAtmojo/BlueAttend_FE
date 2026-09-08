import 'package:bloc/bloc.dart';
import 'package:blueattend/data/model/request/user/user_request_model.dart';
import 'package:blueattend/data/model/response/user_response_model.dart';
import 'package:blueattend/data/repository/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
 final UserRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<GetProfileRequested>(_onProfileProfileRequested);
    on<UpdateProfileRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileProfileRequested(
    GetProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final Either<String, DataUser> result = await profileRepository.getProfile();

    result.fold(
      (error) => emit(ProfileFailure(error: error)),
      (data) => emit(ProfileLoaded(profile: data)),
    );
  }

  Future<void> _onProfileUpdateRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final Either<String, String> result =
        await profileRepository.updateProfile(event.requestModel);

    result.fold(
      (error) => emit(ProfileFailure(error: error)),
      (message) => emit(ProfileUpdateSuccess(message: message)),
    );
  }
}

