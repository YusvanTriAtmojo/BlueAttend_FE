import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:blueattend/data/repository/face_repository.dart';
import 'package:blueattend/service/service_mobile_face_net.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'face_event.dart';
part 'face_state.dart';

class FaceBloc extends Bloc<FaceEvent, FaceState> {
  final FaceRepository faceRepository;

  final ImagePicker _picker = ImagePicker();
  final ServiceMobileFaceNet _faceNet = ServiceMobileFaceNet();

  FaceBloc({required this.faceRepository}) : super(FaceInitial()) {
    on<FaceInitializeRequested>(_onInitialize);
    on<FaceTakePhotoRequested>(_onTakePhoto);
    on<FaceRegisterRequested>(_onRegister);
  }

  Future<void> _onInitialize(
    FaceInitializeRequested event,
    Emitter<FaceState> emit,
  ) async {
    try {
      await _faceNet.initialize();

      emit(FaceReady());
    } catch (e) {
      emit(FaceFailure(error: 'Gagal memuat model wajah: $e'));
    }
  }

  Future<void> _onTakePhoto(
    FaceTakePhotoRequested event,
    Emitter<FaceState> emit,
  ) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        emit(FaceReady());
        return;
      }

      final File imageFile = File(pickedFile.path);

      emit(FacePhotoSelected(image: imageFile));
    } catch (e) {
      emit(FaceFailure(error: 'Gagal mengambil foto'));
    }
  }

  Future<void> _onRegister(
    FaceRegisterRequested event,
    Emitter<FaceState> emit,
  ) async {
    emit(FaceLoading());

    try {
      final embedding = await _faceNet.generateEmbedding(event.image);
      final result = await faceRepository.registerFace(
        fotoProfile: event.image,
        faceEmbedding: embedding,
      );

      result.fold(
        (errorMessage) => emit(FaceFailure(error: errorMessage)),
        (faceResponse) => emit(
          FaceSaveSuccess(
            message: faceResponse.message,
          ),
        ),
      );
    } catch (e) {
      emit(FaceFailure(error: 'Gagal memproses gambar: ${e.toString()}'));
    }
  }
}
