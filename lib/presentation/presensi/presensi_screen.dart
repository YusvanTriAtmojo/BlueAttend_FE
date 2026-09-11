import 'dart:async';
import 'dart:io';
import 'package:blueattend/presentation/presensi/camera/bloc/camera_bloc.dart';
import 'package:blueattend/presentation/presensi/camera/face_camera_screen.dart';
import 'package:blueattend/presentation/presensi/home/header_landing.dart';
import 'package:blueattend/presentation/presensi/scan_qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blueattend/presentation/presensi/bloc/presensi_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final TextEditingController tokenController = TextEditingController();
  String? namaUser;
  bool bleSudahAktif = false;
  final _formKey = GlobalKey<FormState>();

  String? fotoProfile;
  List<int> daftarRssi = [];
  StreamSubscription<BluetoothAdapterState>? bleSubscription;
  bool isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _loadNamaUser();
    _loadProfile();

    bleSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      setState(() {
        bleSudahAktif = state == BluetoothAdapterState.on;
      });
    });
  }

  Future<void> _loadProfile() async {
    final foto = await storage.read(key: "foto_profile");
    if (!mounted) return;
    setState(() {
      fotoProfile = foto;
    });
  }

  Future<void> _loadNamaUser() async {
    final nama = await storage.read(key: 'nama_user');
    if (!mounted) return;
    setState(() {
      namaUser = nama;
    });
  }

  Future<void> _scanBarcode() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ScanQr(
              deteksi: (value) {
                tokenController.text = value;
              },
            ),
      ),
    );
  }

  void _showLoadingDialog(String text) {
    if (isDialogShowing) {
      Navigator.pop(context);
      isDialogShowing = false;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text(text)),
            ],
          ),
        );
      },
    );
    isDialogShowing = true;
  }

  void _closeDialog() {
    if (!mounted) return;

    if (isDialogShowing && Navigator.canPop(context)) {
      Navigator.pop(context);
      isDialogShowing = false;
    }
  }

  @override
  void dispose() {
    bleSubscription?.cancel();
    tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PresensiBloc, PresensiState>(
      listener: (context, state) async {
        if (state is PresensiLoading) {
          _showLoadingDialog("Loading...");
        }

        if (state is PresensiMencariPerangkat) {
          _showLoadingDialog("Mencari BLE...");
        }

        if (state is PresensiPerangkatDitemukan) {
          _showLoadingDialog("Perangkat BLE ditemukan...");
        }

        if (state is PresensiBleReady) {
          _closeDialog();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bluetooth BLE siap digunakan',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF81C784),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (state is PresensiSuccess) {
          _closeDialog();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (state is PresensiFailure) {
          _closeDialog();

          ScaffoldMessenger.of(context).showSnackBar(
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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFEAF3FF),
        body: SafeArea(
          child: Column(
            children: [
              HeaderLanding(),
              SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Halaman Presensi',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            fotoProfile != null && fotoProfile!.isNotEmpty
                                ? NetworkImage(fotoProfile!)
                                : const AssetImage('assets/images/profile.png')
                                    as ImageProvider,
                      ),

                      SizedBox(height: 30),

                      CheckboxListTile(
                        title: Row(
                          children: [
                            Text(
                              'Aktifkan Bluetooth',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.bluetooth,
                              color: Colors.blueAccent,
                              size: 22,
                            ),
                          ],
                        ),
                        subtitle: Text('Digunakan untuk presensi'),
                        value: bleSudahAktif,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged:
                            bleSudahAktif
                                ? null
                                : (_) {
                                  context.read<PresensiBloc>().add(
                                    PastikanBleOn(),
                                  );
                                },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Token',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 5,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: tokenController,
                                      enabled: bleSudahAktif,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan Token Presensi',
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed:
                                              bleSudahAktif
                                                  ? _scanBarcode
                                                  : null,
                                          icon: Icon(
                                            Icons.qr_code_scanner,
                                            size: 40,
                                          ),
                                          color: Color(0xFF004CB8),
                                          tooltip: 'Scan QR / Barcode',
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Token harus diisi';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed:
                                    bleSudahAktif
                                        ? () async {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();

                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          final tokenInput =
                                              tokenController.text.trim();

                                          final presensiBloc =
                                              context.read<PresensiBloc>();

                                          final scaffoldMessenger =
                                              ScaffoldMessenger.of(context);

                                          final File? fotoWajah = await Navigator.push<File>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider(
                                                create: (_) => CameraBloc(
                                                  faceDetector: FaceDetector(
                                                    options: FaceDetectorOptions(
                                                      performanceMode: FaceDetectorMode.fast,
                                                    ),
                                                  ),
                                                ),
                                                child: FaceCameraScreen(),
                                              ),
                                            ),
                                          );

                                          if (!mounted) return;

                                          if (fotoWajah == null) {
                                            scaffoldMessenger
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Pengambilan foto wajah dibatalkan',
                                                  ),
                                                ),
                                              );

                                            return;
                                          }

                                          presensiBloc.add(
                                            KirimPresensi(
                                              token: tokenInput,
                                              fotoWajah: fotoWajah,
                                            ),
                                          );
                                        }
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF004CB8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Kirim',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
