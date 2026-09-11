part of 'camera_bloc.dart';

sealed class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

final class InitializeCamera extends CameraEvent {
  const InitializeCamera();
}

final class ProsesCameraFrame extends CameraEvent {
  final CameraImage image;

  const ProsesCameraFrame({
    required this.image,
  });

  @override
  List<Object?> get props => [image];
}

final class TakePicture extends CameraEvent {
  const TakePicture();
}

final class ResetFaceCamera extends CameraEvent {
  const ResetFaceCamera();
}
