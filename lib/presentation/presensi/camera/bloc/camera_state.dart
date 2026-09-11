part of 'camera_bloc.dart';

@immutable
sealed class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

final class CameraInitial extends CameraState {}

final class CameraLoading extends CameraState {}

final class CameraReady extends CameraState {}

final class FaceCameraNoFace extends CameraState {
  final String message;

  const FaceCameraNoFace({
    this.message = 'Wajah tidak terdeteksi',
  });

  @override
  List<Object?> get props => [message];
}

final class FaceCameraMultipleFaces extends CameraState {
  final String message;

  const FaceCameraMultipleFaces({
    this.message = 'Pastikan hanya 1 wajah',
  });

  @override
  List<Object?> get props => [message];
}

final class FaceCameraNotCentered extends CameraState {
  final String message;

  const FaceCameraNotCentered({
    this.message = 'Posisikan wajah di tengah',
  });

  @override
  List<Object?> get props => [message];
}

final class FaceCameraTooFar extends CameraState {
  final String message;

  const FaceCameraTooFar({
    this.message = 'Dekatkan wajah ke kamera',
  });

  @override
  List<Object?> get props => [message];
}

final class FaceCameraReady extends CameraState {
  final String message;

  const FaceCameraReady({
    this.message = 'Wajah siap',
  });

  @override
  List<Object?> get props => [message];
}

final class CameraTakingPicture extends CameraState {}

final class CameraPhotoTaken extends CameraState {
  final XFile file;

  const CameraPhotoTaken({
    required this.file,
  });

  @override
  List<Object?> get props => [file];
}

final class FaceCameraError extends CameraState {
  final String message;

  const FaceCameraError(this.message);

  @override
  List<Object?> get props => [message];
}
