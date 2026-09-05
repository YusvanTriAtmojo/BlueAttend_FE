part of 'face_bloc.dart';

@immutable
sealed class FaceState {}

final class FaceInitial extends FaceState {}

final class FaceLoading extends FaceState {}

final class FaceReady extends FaceState {}

final class FacePhotoSelected extends FaceState {
  final File image;

  FacePhotoSelected({
    required this.image,
  });
}

final class FaceSaveSuccess extends FaceState {
  final String message;

  FaceSaveSuccess({
    required this.message,
  });
}

final class FaceFailure extends FaceState {
  final String error;

  FaceFailure({
    required this.error,
  });
}