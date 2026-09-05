part of 'face_bloc.dart';

@immutable
sealed class FaceEvent {}

final class FaceInitializeRequested extends FaceEvent {}

final class FaceTakePhotoRequested extends FaceEvent {}

final class FacePickGalleryRequested extends FaceEvent {}

final class FaceRegisterRequested extends FaceEvent {
  final File image;

  FaceRegisterRequested({
    required this.image,
  });
}