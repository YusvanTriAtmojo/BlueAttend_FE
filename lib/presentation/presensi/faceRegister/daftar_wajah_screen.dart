import 'dart:io';

import 'package:blueattend/presentation/presensi/camera/bloc/camera_bloc.dart';
import 'package:blueattend/presentation/presensi/camera/face_camera_screen.dart';
import 'package:blueattend/presentation/presensi/faceRegister/bloc/face_bloc.dart';
import 'package:blueattend/presentation/presensi/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DaftarWajahScreen extends StatefulWidget {
  const DaftarWajahScreen({super.key});

  @override
  State<DaftarWajahScreen> createState() => _DaftarWajahScreenState();
}

class _DaftarWajahScreenState extends State<DaftarWajahScreen> {
  File? image;

  @override
  void initState() {
    super.initState();

    context.read<FaceBloc>().add(FaceInitializeRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FaceBloc, FaceState>(
        listener: (context, state) {
          if (state is FacePhotoSelected) {
            setState(() {
              image = state.image;
            });

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    'Foto berhasil dipilih',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Color(0xFF81C784),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  duration: const Duration(seconds: 3),
                ),
              );
          }
          if (state is FaceSaveSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  duration: const Duration(seconds: 3),
                ),
              );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
            );
          }

          if (state is FaceFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.error,
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Color(0xFFF2A7A0),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  duration: const Duration(seconds: 3),
                ),
              );
          }
        },

        builder: (context, state) {
          final bool loading = state is FaceLoading;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Daftarkan Wajah Anda',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Gunakan foto wajah yang jelas '
                    'dan pastikan hanya satu wajah '
                    'yang terlihat.',
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 28),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 260,
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            width: 2,
                            color: image != null
                                ? Colors.green
                                : Color(0xFF6C9BD2),
                          ),
                        ),

                        clipBehavior: Clip.antiAlias,

                        child: image != null
                            ? Image.file(image!, fit: BoxFit.cover)
                            : Center(
                                child: Icon(
                                  Icons.face,
                                  size: 100,
                                  color: Color(0xFF6C9BD2),
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  if (image != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Foto siap didaftarkan',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: loading
                          ? null
                          : () async {
                              final File? capturedImage =
                                  await Navigator.push<File>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider(
                                        create: (_) => CameraBloc(
                                          faceDetector: FaceDetector(
                                            options: FaceDetectorOptions(
                                              performanceMode:
                                                  FaceDetectorMode.fast,
                                            ),
                                          ),
                                        ),
                                        child: FaceCameraScreen(),
                                      ),
                                    ),
                                  );

                              if (capturedImage != null && mounted) {
                                setState(() {
                                  image = capturedImage;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C9BD2),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        image == null ? 'Ambil Foto' : 'Ambil Foto Ulang',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: image != null && !loading
                          ? () {
                              context.read<FaceBloc>().add(
                                FaceRegisterRequested(image: image!),
                              );
                            }
                          : null,
                      child: loading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Simpan Wajah',
                              style: TextStyle(color: Color(0xFF6C9BD2)),
                            ),
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
