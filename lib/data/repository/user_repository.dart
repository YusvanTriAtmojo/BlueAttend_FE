import 'dart:convert';
import 'dart:io';

import 'package:blueattend/data/model/request/user/user_request_model.dart';
import 'package:blueattend/data/model/response/user_response_model.dart';
import 'package:blueattend/service/service_http_client.dart';
import 'package:dartz/dartz.dart';

class UserRepository {
  final ServiceHttpClient httpClient;

  UserRepository(this.httpClient);


  Future<Either<String, DataUser>> getProfile() async {
    try {
      final response = await httpClient.get("peserta/profile");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final user= DataUser.fromJson(jsonResponse['data']);
        return Right(user);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal mengambil data User');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Future<Either<String, String>> updateProfile(
    UserRequestModel request) async {
    try {
      final response = await httpClient.put(
        "peserta/update",
        request.toJson(),
      );

      if (response.statusCode == 200) {
        return Right("Data User berhasil diperbarui");
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal memperbarui User');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Either<String, T> _infopenyimpangan<T>(Object e) {
    if (e is SocketException) {
      return Left("Tidak ada koneksi internet");
    } else if (e is HttpException) {
      return Left("Kesalahan HTTP: ${e.message}");
    } else if (e is FormatException) {
      return Left("Format respons tidak valid");
    } else {
      return Left("Terjadi kesalahan tak terduga: $e");
    }
  }
}
