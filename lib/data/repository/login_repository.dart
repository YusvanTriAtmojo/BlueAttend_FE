import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blueattend/data/model/request/auth/login_request_model.dart';
import 'package:blueattend/data/model/response/auth_response_model.dart';
import 'package:blueattend/service/service_http_client.dart';


class AuthRepository {
  final ServiceHttpClient _serviceHttpClient;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  AuthRepository(this._serviceHttpClient);

  //Login
  Future<Either<String, AuthResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    try {
      final response = await _serviceHttpClient.post(
        "login",
        requestModel.toJson(),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final loginResponse = AuthResponseModel.fromJson(jsonResponse);

        final user = loginResponse.user;

        await secureStorage.write(key: "authToken", value: user.token);
        await secureStorage.write(key: "userRole", value: user.role);
        await secureStorage.write(key: "userId", value: user.id.toString());
        await secureStorage.write(key: "nama_user", value: user.nama);

        log("Login successful: ${loginResponse.message}");
        return Right(loginResponse);
      } else {
        final message = jsonResponse['message'] ?? "Login gagal, periksa kredensial Anda.";
        log("Login failed: $message");
        return Left(message);
      }
    } catch (e, stackTrace) {
      log("Error in login: $e", stackTrace: stackTrace);
      return const Left("Terjadi kesalahan saat login, coba lagi nanti.");
    }
  }
  
  //Sudah Login
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: "authToken");
    if (token == null || token.isEmpty) return false;

    try {
      final response = await _serviceHttpClient.get("me");

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        await secureStorage.delete(key: "authToken");
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //Logout
  Future<void> logout() async {
    try {
      final token = await secureStorage.read(key: "authToken");

      if (token != null && token.isNotEmpty) {
        await _serviceHttpClient.postWithToken("logout", {});
      }

      await secureStorage.delete(key: "authToken");
      await secureStorage.delete(key: "userRole");
      await secureStorage.delete(key: "userId");

      log("Token & data user dihapus dari storage");
    } catch (e, stackTrace) {
      log("Error saat logout: $e", stackTrace: stackTrace);
    }
  }

}
