import 'package:blueattend/presentation/auth/bloc/login_bloc.dart';
import 'package:blueattend/presentation/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HeaderLanding extends StatefulWidget {
  const HeaderLanding({super.key});

  @override
  State<HeaderLanding> createState() => _HeaderLandingState();
}

class _HeaderLandingState extends State<HeaderLanding> {
  int currentPage = 1;
  final int itemsPerPage = 5;

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? namaUser;

  @override
  void initState() {
    super.initState();
    _loadNamaUser();
  }

  Future<void> _loadNamaUser() async {
    final nama = await storage.read(key: 'nama_user');
    setState(() {
      namaUser = nama;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
      child: Container(
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Stack(
          children: [
            // Background utama
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF002F87), Color(0xFF004CB8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(13),
                ),
              ),
            ),

            // Lingkaran kiri bawah
            Positioned(
              left: -150,
              bottom: -150,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(31),
                ),
              ),
            ),

            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C9BD2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(300),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -70,
              right: -40,
              child: Container(
                width: 200,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(300),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
              ),
            ),

            // Isi Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 120,
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      bottom: 5,
                      top: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Blue',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'Attend',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C9BD2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person_2_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              namaUser ?? 'Loading...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20), // naik 15 px
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      offset: const Offset(0, 55),
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'logout') {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                titlePadding: EdgeInsets.zero,
                                title: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF002F87),
                                        Color(0xFF6C9BD2),
                                        Color(0xFFFFF3CD),
                                      ],
                                      stops: [0.0, 0.6, 1.0],
                                    ),
                                  ),
                                  child: Text(
                                    "Konfirmasi Logout",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                content: Text(
                                  "Apakah Anda yakin ingin keluar dari aplikasi ?",
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(dialogContext),
                                        child: Text(
                                          "Batal",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF6C9BD2),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          context.read<LoginBloc>().add(
                                            LogoutRequested(),
                                          );
                                        },
                                        child: const Text(
                                          "Keluar",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem<String>(
                              height: 36,
                              value: 'logout',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
