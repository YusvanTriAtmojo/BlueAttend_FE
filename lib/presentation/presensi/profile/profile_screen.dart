import 'package:blueattend/data/model/response/user_response_model.dart';
import 'package:blueattend/presentation/auth/bloc/login_bloc.dart';
import 'package:blueattend/presentation/auth/login_screen.dart';
import 'package:blueattend/presentation/presensi/faceRegister/daftar_wajah_screen.dart';
import 'package:blueattend/presentation/presensi/profile/bloc/profile_bloc.dart';
import 'package:blueattend/presentation/presensi/profile/profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? fotoProfile;

  @override
  void initState() {
    super.initState();
    context.read<Bloc>().add(GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7A8FB1), Color(0xFFE7EBFF)],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.error,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.white,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF002F87)),
                  );
                } else if (state is ProfileLoaded) {
                  final DataUser profile = state.profile;

                  return ListView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 60,
                    ),
                    children: [
                      SizedBox(height: 16),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage:
                                  fotoProfile != null && fotoProfile!.isNotEmpty
                                      ? NetworkImage(fotoProfile!)
                                      : const AssetImage(
                                            'assets/images/profile.png',
                                          )
                                          as ImageProvider,
                            ),
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DaftarWajahScreen(),
                                    ),
                                  );
                                },
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Data Diri",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002F87),
                        ),
                      ),
                      SizedBox(height: 10),
                      dataProfile(Icons.person, "Nama", profile.nama),
                      dataProfile(Icons.key_outlined, "NIP", profile.nip),
                      dataProfile(Icons.email, "Email", profile.email),
                      dataProfile(Icons.phone, "Nomor Telepon", profile.notlp),
                      dataProfile(Icons.location_on, "Alamat", profile.alamat),
                    ],
                  );
                } else {
                  return Center(child: Text("Belum ada data Klien"));
                }
              },
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: FloatingActionButton(
            onPressed: () async {
              final state = context.read<ProfileBloc>().state;
              if (state is ProfileLoaded) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProfileEditScreen(profile: state.profile),
                  ),
                );
                if (!context.mounted) return;
                if (result == true) {
                  context.read<ProfileBloc>().add(GetProfileRequested());
                }
              }
            },
            backgroundColor: Color(0xFF002F87),
            child: Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget dataProfile(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF003C97),
            blurRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFF7A00)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002C5A),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
