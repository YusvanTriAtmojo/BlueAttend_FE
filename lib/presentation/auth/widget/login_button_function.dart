import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blueattend/data/model/request/auth/login_request_model.dart';
import 'package:blueattend/presentation/admin/admin_screen.dart';
import 'package:blueattend/presentation/auth/bloc/login_bloc.dart';
import 'package:blueattend/presentation/presensi/home/home_screen.dart';

class LoginButtonFunction extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButtonFunction({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error,
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Color(0xFFF2A7A0),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is LoginSuccess) {
          final role = state.responseModel.user.role;
          final storage = FlutterSecureStorage();

          await storage.write(key: "userRole", value: role);
          await storage.write(key: "isLoggedIn", value: "true");

          if (!context.mounted) return;
          if (role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => AdminScreen()),
              (route) => false,
            );
          } else if (role == 'peserta') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Akun tidak dikenali",
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Color(0xFFF2A7A0),
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
          }
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                state is LoginLoading
                    ? null
                    : () {
                      if (formKey.currentState!.validate()) {
                        final request = LoginRequestModel(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        context.read<LoginBloc>().add(
                          LoginRequested(requestModel: request),
                        );
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C9BD2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              state is LoginLoading ? 'Memuat...' : 'Login',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
