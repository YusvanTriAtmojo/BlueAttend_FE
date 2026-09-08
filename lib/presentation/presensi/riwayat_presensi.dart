import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:blueattend/presentation/auth/bloc/login_bloc.dart';
import 'package:blueattend/presentation/auth/login_screen.dart';
import 'package:blueattend/presentation/presensi/bloc/presensi_bloc.dart';

class RiwayatPresensi extends StatefulWidget {
  const RiwayatPresensi({super.key});

  @override
  State<RiwayatPresensi> createState() => _RiwayatPresensiState();
}

class _RiwayatPresensiState extends State<RiwayatPresensi> {
  int currentPage = 1;
  final int itemsPerPage = 5;

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? namaUser;

  @override
  void initState() {
    super.initState();
    _loadNamaUser();
    context.read<PresensiBloc>().add(RiwayatRequested());
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
      child: Scaffold(
        backgroundColor: Color(0xFFEAF3FF),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFF004CB8)],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.png', height: 50),
                    Row(
                      children: [
                        Icon(
                          Icons.person_2_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          namaUser ?? 'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: Colors.white,
                          offset: Offset(0, 55),
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
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
                                                () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                            child: Text(
                                              "Batal",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF6C9BD2,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              context.read<LoginBloc>().add(
                                                LogoutRequested(),
                                              );
                                            },
                                            child: Text(
                                              "Keluar",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
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
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Riwayat Presensi",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<PresensiBloc, PresensiState>(
                  builder: (context, state) {
                    if (state is PresensiLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is PresensiFailure) {
                      return Center(child: Text("Gagal: ${state.error}"));
                    }

                    if (state is RiwayatPresensiSuccess) {
                      final data = state.data;

                      if (data.isEmpty) {
                        return Center(
                          child: Text("Belum ada riwayat presensi"),
                        );
                      }
                      data.sort(
                        (a, b) => DateTime.parse(
                          b.tanggal,
                        ).compareTo(DateTime.parse(a.tanggal)),
                      );

                      final totalPages = (data.length / itemsPerPage)
                          .ceil()
                          .clamp(1, 100);

                      final startIndex = (currentPage - 1) * itemsPerPage;
                      final endIndex =
                          (startIndex + itemsPerPage > data.length)
                              ? data.length
                              : startIndex + itemsPerPage;

                      final currentData = data.sublist(startIndex, endIndex);

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: currentData.length,
                                itemBuilder: (context, index) {
                                  final item = currentData[index];

                                  final tanggal = DateFormat(
                                    'd MMM yyyy, HH:mm',
                                  ).format(DateTime.parse(item.tanggal));

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          bottom: 1,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF6C9BD2),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 15,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  26,
                                                ),
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: Color(0xFFE0E7E3),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.event,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      tanggal,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF6C9BD2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            if (totalPages > 1)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        currentPage > 1
                                            ? () =>
                                                setState(() => currentPage--)
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF004CB8),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                        color: Color(0xFFE0E7E3),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text("Prev"),
                                  ),
                                  SizedBox(width: 40),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6C9BD2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "$currentPage / $totalPages",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 40),
                                  ElevatedButton(
                                    onPressed:
                                        currentPage < totalPages
                                            ? () =>
                                                setState(() => currentPage++)
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF004CB8),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text("Next"),
                                  ),
                                ],
                              ),
                            SizedBox(height: 10),

                            Text(
                              "Halaman $currentPage dari $totalPages",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(child: Text("Memuat data..."));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
