import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/camera_bloc.dart';

class FaceCameraScreen extends StatefulWidget {
  const FaceCameraScreen({super.key});

  @override
  State<FaceCameraScreen> createState() => _FaceCameraScreenState();
}

class _FaceCameraScreenState extends State<FaceCameraScreen> {

  @override
  void initState() {
    super.initState();
    context.read<CameraBloc>().add(const InitializeCamera());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraBloc, CameraState>(
      listener: (context, state) {
        if (state is CameraPhotoTaken) {
          Navigator.pop(context, File(state.file.path));
        }
        if (state is FaceCameraError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          final cameraBloc = context.read<CameraBloc>();
          final CameraController? controller = cameraBloc.controller;

          final bool canTakePicture = state is FaceCameraReady;

          final bool isTakingPicture = state is CameraTakingPicture;

          final String message = _getMessage(state);

          final Color guideColor = canTakePicture ? Color(0xFF6C9BD2) : Colors.white;

          // kamera belum siap
          if (controller == null || !controller.value.isInitialized) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: const SafeArea(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            );
          }

          // kamera siap
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  // preview kamera
                  Positioned.fill(child: CameraPreview(controller)),

                  // face guide
                  Positioned.fill(
                    child: CustomPaint(
                      painter: FaceGuidePainter(color: guideColor),
                    ),
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed:
                            isTakingPicture
                                ? null
                                : () {
                                  Navigator.pop(context);
                                },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Posisikan Wajah',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 125,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                canTakePicture
                                    ? Color(0xFF6C9BD2)
                                    : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap:
                            canTakePicture && !isTakingPicture
                                ? () {
                                  context.read<CameraBloc>().add(
                                    const TakePicture(),
                                  );
                                }
                                : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                canTakePicture
                                    ? Colors.white
                                    : Colors.grey.shade600,
                            border: Border.all(
                              color:
                                  canTakePicture
                                      ? Colors.green
                                      : Color(0xFF6C9BD2),
                              width: 5,
                            ),
                          ),
                          child:
                              isTakingPicture
                                  ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  )
                                  : Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color:
                                        canTakePicture
                                            ? Color(0xFF6C9BD2)
                                            : Colors.grey.shade300,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // pesan state
  String _getMessage(CameraState state) {
    if (state is FaceCameraNoFace) {
      return state.message;
    }

    if (state is FaceCameraMultipleFaces) {
      return state.message;
    }

    if (state is FaceCameraNotCentered) {
      return state.message;
    }

    if (state is FaceCameraTooFar) {
      return state.message;
    }

    if (state is FaceCameraReady) {
      return state.message;
    }

    if (state is FaceCameraError) {
      return state.message;
    }

    if (state is CameraTakingPicture) {
      return 'Mengambil foto...';
    }

    return 'Posisikan wajah di dalam garis';
  }
}

// guide painter wajah
class FaceGuidePainter extends CustomPainter {
  final Color color;

  FaceGuidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    // batasi lebar oval agar tidak terlalu memenuhi layar (misal: max 70%-75% lebar layar)
    final ovalWidth = size.width * 0.72; 

    // rasio wajah ideal (tinggi = lebar * 1.35 s/d 1.4)
    final ovalHeight = ovalWidth * 1.38;

    // posisi di tengah layar horizontal & sedikit di atas tengah vertikal (eye-level)
    final left = (size.width - ovalWidth) / 2;
    final top = (size.height - ovalHeight) / 2 - (size.height * 0.05); 

    final rect = Rect.fromLTWH(left, top, ovalWidth, ovalHeight);

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant FaceGuidePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
