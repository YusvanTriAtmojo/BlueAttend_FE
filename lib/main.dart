import 'package:blueattend/data/repository/ble_repository.dart';
import 'package:blueattend/data/repository/face_repository.dart';
import 'package:blueattend/data/repository/user_repository.dart';
import 'package:blueattend/presentation/admin/ble/bloc/ble_bloc.dart';
import 'package:blueattend/presentation/presensi/camera/bloc/camera_bloc.dart';
import 'package:blueattend/presentation/presensi/faceRegister/bloc/face_bloc.dart';
import 'package:blueattend/presentation/presensi/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:blueattend/data/repository/login_repository.dart';
import 'package:blueattend/data/repository/presensi_repository.dart';
import 'package:blueattend/data/repository/sesi_repository.dart';
import 'package:blueattend/presentation/admin/admin_screen.dart';
import 'package:blueattend/presentation/admin/sesi/bloc/sesi_bloc.dart';
import 'package:blueattend/presentation/auth/bloc/login_bloc.dart';
import 'package:blueattend/presentation/auth/login_screen.dart';
import 'package:blueattend/presentation/presensi/bloc/presensi_bloc.dart';
import 'package:blueattend/presentation/presensi/home/home_screen.dart';
import 'package:blueattend/presentation/presensi/presensi_screen.dart';
import 'package:blueattend/service/service_http_client.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final authRepo = AuthRepository(ServiceHttpClient());
  final storage = const FlutterSecureStorage();
  Widget startPage;
  final isLoggedIn = await authRepo.isLoggedIn();

  if (isLoggedIn) {
    final role = await storage.read(key: "userRole");
      switch (role) {
        case "admin":
          startPage = const AdminScreen();
          break;
        case "peserta":
          startPage = HomeScreen();
          break;

        default:
          startPage = PresensiScreen();
      }
  } else {
    startPage = const LoginScreen();
  }

  runApp(MyApp(startPage: startPage));
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => LoginBloc(
                authRepository: AuthRepository(ServiceHttpClient()),
              ),
        ),
        BlocProvider(
          create:
              (context) => PresensiBloc(
                presensiRepository: PresensiRepository(ServiceHttpClient()),
              ),
        ),
        BlocProvider(
          create:
              (context) =>
                  BleBloc(bleRepository: BleRepository(ServiceHttpClient())),
        ),
        BlocProvider(
          create:
              (context) =>
                  SesiBloc(sesiRepository: SesiRepository(ServiceHttpClient())),
        ),
        BlocProvider(
          create:
              (context) => ProfileBloc(
                profileRepository: UserRepository(ServiceHttpClient()),
              ),
        ),
        BlocProvider(
          create:
              (context) =>
                  FaceBloc(faceRepository: FaceRepository(ServiceHttpClient())),
        ),
        BlocProvider(
          create: (context) => CameraBloc(
            faceDetector: FaceDetector(
              options: FaceDetectorOptions(
                enableContours: true,
                enableLandmarks: true,
                enableClassification: true,
                enableTracking: true,
                performanceMode: FaceDetectorMode.accurate,
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return SafeArea(child: child!);
        },
        title: 'BlueAttend',
        debugShowCheckedModeBanner: false,
        locale: const Locale('id', 'ID'),

        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],

        localizationsDelegates: GlobalMaterialLocalizations.delegates,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF002F87)),
        ),
        home: startPage,
      ),
    );
  }
}
