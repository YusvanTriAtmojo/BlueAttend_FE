import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:blueattend/data/repository/face_repository.dart';
import 'package:blueattend/service/service_mobile_face_net.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'face_event.dart';
part 'face_state.dart';

class FaceBloc extends Bloc<FaceEvent, FaceState> {
  final FaceRepository faceRepository;

  final ImagePicker _picker = ImagePicker();
  final ServiceMobileFaceNet _faceNet = ServiceMobileFaceNet();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

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

      await result.fold(
        (errorMessage) async {emit(FaceFailure(error: errorMessage));},
        (faceResponse) async {
          // ambil foto terbaru dari response data
          final fotoProfile = faceResponse.fotoProfile;

          // simpan foto ke secure storage
          if (fotoProfile != null && fotoProfile.isNotEmpty) {
            await _storage.write(
              key: 'foto_profile',
              value: fotoProfile,
            );
          }
          emit(FaceSaveSuccess(message: faceResponse.message),
          );
        },
      );
    } catch (e) {
      emit(
        FaceFailure(
          error: 'Gagal memproses gambar: ${e.toString()}'));
    }
  }
}