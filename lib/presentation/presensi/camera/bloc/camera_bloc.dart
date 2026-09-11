import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final FaceDetector faceDetector;

  CameraController? _controller;

  bool _isDetecting = false;
  bool _isTakingPicture = false;

  CameraBloc({ required this.faceDetector }) : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<ProsesCameraFrame>(_onProcessCameraFrame);
    on<TakePicture>(_onTakePicture);
    on<ResetFaceCamera>(_onResetFaceCamera);
  }

  CameraController? get controller => _controller;

  // menginisialisasi kamera
  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      emit(CameraLoading());

      // Jika sebelumnya masih ada controller, dispose terlebih dahulu.
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      // Ambil daftar kamera
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Kamera tidak ditemukan');
      }

      // cari kamera depan
      final frontCamera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Buat controller
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _controller = controller;

      // inisialisasi kamera
      await controller.initialize();

      // mulai stream kamera
      await controller.startImageStream((image) {
        if (isClosed) {
          return;
        }
        add(
          ProsesCameraFrame(
            image: image,
          ),
        );
      });

      if (isClosed) {
        return;
      }

      emit(CameraReady());
    } catch (e, stackTrace) {
      debugPrint(
        'Initialize camera error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      emit(
        FaceCameraError(
          'Gagal membuka kamera: $e',
        ),
      );
    }
  }

  // proses frame kamera
  Future<void> _onProcessCameraFrame(
    ProsesCameraFrame event,
    Emitter<CameraState> emit,
  ) async {
    // jangan proses frame baru jika frame sebelumnya masih diproses oleh ML Kit.
    if (_isDetecting) {
      return;
    }

    // jangan proses jika kamera tidak tersedia.
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    // jangan proses frame ketika sedang mengambil foto.
    if (_isTakingPicture) {
      return;
    }

    _isDetecting = true;

    try {
      final inputImage = _convertCameraImage(
        event.image,
        controller,
      );

      if (inputImage == null) {
        return;
      }

      final faces =
          await faceDetector.processImage(inputImage);

      // jika tidak ada wajah
      if (faces.isEmpty) {
        emit(
          const FaceCameraNoFace(
            message: 'Wajah tidak terdeteksi',
          ),
        );

        return;
      }

      // jika lebih dari 1 wajah
      if (faces.length > 1) {
        emit(
          const FaceCameraMultipleFaces(
            message: 'Pastikan hanya 1 wajah',
          ),
        );

        return;
      }

      final face = faces.first;

      final imageWidth =
          event.image.width.toDouble();

      final imageHeight =
          event.image.height.toDouble();

      final faceBox = face.boundingBox;

      // cek posisi wajah
      final faceCenterX =
          faceBox.center.dx;

      final faceCenterY =
          faceBox.center.dy;

      final imageCenterX =
          imageWidth / 2;

      final imageCenterY =
          imageHeight / 2;

      // toleransi posisi wajah 20%
      final maxOffsetX =
          imageWidth * 0.20;

      final maxOffsetY =
          imageHeight * 0.20;

      final isCentered =
          (faceCenterX - imageCenterX).abs() <=
              maxOffsetX &&
          (faceCenterY - imageCenterY).abs() <=
              maxOffsetY;

      if (!isCentered) {
        emit(
          const FaceCameraNotCentered(
            message: 'Posisikan wajah di tengah',
          ),
        );

        return;
      }

      // cek ukuran wajah
      // Wajah minimal sekitar 25% tinggi gambar.
      final minimumFaceHeight =
          imageHeight * 0.25;

      final isSizeValid =
          faceBox.height >= minimumFaceHeight;

      if (!isSizeValid) {
        emit(
          const FaceCameraTooFar(
            message: 'Dekatkan wajah ke kamera',
          ),
        );

        return;
      }

      emit(
        const FaceCameraReady(
          message: 'Wajah siap ✓',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Face detection error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      emit(
        const FaceCameraError(
          'Terjadi kesalahan mendeteksi wajah',
        ),
      );
    } finally {
      _isDetecting = false;
    }
  }

  // ambil gambar
  Future<void> _onTakePicture(
    TakePicture event,
    Emitter<CameraState> emit,
  ) async {
    if (_isTakingPicture) {
      return;
    }

    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }
    _isTakingPicture = true;

    try {
      emit(CameraTakingPicture());

      // stop stream terlebih dahulu
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      // Ambil foto
      final XFile file =
          await controller.takePicture();

      if (isClosed) {
        return;
      }

      emit(
        CameraPhotoTaken(
          file: file,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Take picture error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      emit(
        const FaceCameraError(
          'Gagal mengambil foto',
        ),
      );

      // Jika gagal mengambil foto, hidupkan kembali image stream.
      try {
        if (controller.value.isInitialized &&
            !controller.value.isStreamingImages) {
          await controller.startImageStream((image) {
            if (isClosed) {
              return;
            }
            add(
              ProsesCameraFrame(
                image: image,
              ),
            );
          });
        }
      } catch (e) {
        debugPrint(
          'Gagal memulai ulang camera stream: $e',
        );
      }
    } finally {
      _isTakingPicture = false;
    }
  }

  // convert kamera image
  InputImage? _convertCameraImage(
    CameraImage image,
    CameraController controller,
  ) {
    try {
      /*
       * Google ML Kit Android menggunakan NV21.
       *
       * Camera Flutter:
       *
       * Plane 0 = Y
       * Plane 1 = U
       * Plane 2 = V
       *
       * NV21:
       *
       * Y + VU
       */

      final WriteBuffer allBytes =
          WriteBuffer();

      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      // Y PLANE
      allBytes.putUint8List(
        yPlane.bytes,
      );

      // UV PLANE
      final uvPixelStride =
          uPlane.bytesPerPixel ?? 1;

      if (uvPixelStride == 2) {
        /*
         * Android menggunakan UV
         * interleaved.
         *
         * NV21 membutuhkan VU.
         */

        final uvLength =
            vPlane.bytes.length;

        final Uint8List vuBytes =
            Uint8List(uvLength);

        for (
          int i = 0;
          i < uvLength;
          i += 2
        ) {
          if (i + 1 < uvLength) {
            vuBytes[i] =
                vPlane.bytes[i];

            vuBytes[i + 1] =
                uPlane.bytes[i];
          }
        }

        allBytes.putUint8List(
          vuBytes,
        );
      } else {
        /*
         * Apabila pixel stride bukan 2,
         * susun VU secara manual.
         */

        final int uvWidth =
            image.width ~/ 2;

        final int uvHeight =
            image.height ~/ 2;

        for (
          int row = 0;
          row < uvHeight;
          row++
        ) {
          final int uRowStart =
              row * uPlane.bytesPerRow;

          final int vRowStart =
              row * vPlane.bytesPerRow;

          for (
            int col = 0;
            col < uvWidth;
            col++
          ) {
            final int uIndex =
                uRowStart +
                col * uvPixelStride;

            final int vIndex =
                vRowStart +
                col *
                    (vPlane.bytesPerPixel ?? 1);

            if (vIndex <
                    vPlane.bytes.length &&
                uIndex <
                    uPlane.bytes.length) {
              // NV21 = V kemudian U
              allBytes.putUint8(
                vPlane.bytes[vIndex],
              );

              allBytes.putUint8(
                uPlane.bytes[uIndex],
              );
            }
          }
        }
      }

      final bytes =
          allBytes.done()
              .buffer
              .asUint8List();

      // rotasi camera
      final camera =
          controller.description;

      InputImageRotation rotation;
      switch (
        camera.sensorOrientation
      ) {
        case 90:
          rotation =
              InputImageRotation.rotation90deg;
          break;

        case 180:
          rotation =
              InputImageRotation.rotation180deg;
          break;

        case 270:
          rotation =
              InputImageRotation.rotation270deg;
          break;

        default:
          rotation =
              InputImageRotation.rotation0deg;
      }

      // metadata
      final metadata =
          InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow:
            yPlane.bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Convert camera image error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );
      return null;
    }
  }

  // reset kamera
  void _onResetFaceCamera(
    ResetFaceCamera event,
    Emitter<CameraState> emit,
  ) {
    emit(CameraInitial());
  }

  // tutup stream kamera
  @override
  Future<void> close() async {
    try {
      final controller = _controller;

      if (controller != null) {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }

        await controller.dispose();
        _controller = null;
      }

      await faceDetector.close();
    } catch (e) {
      debugPrint(
        'CameraBloc close error: $e',
      );
    }

    return super.close();
  }
}
