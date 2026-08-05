import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:blueattend/data/model/request/sesi/sesi_request_model.dart';
import 'package:blueattend/data/model/response/get_all_sesi_response_model.dart';
import 'package:blueattend/service/service_http_client.dart';

class SesiRepository {
  final ServiceHttpClient httpClient;

  SesiRepository(this.httpClient);

  Future<Either<String, GetAllSesiResponseModel>> getAllSesi() async {
    try {
      final response = await httpClient.get("sesi");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final sesiResponse = GetAllSesiResponseModel.fromJson(jsonResponse);
        return Right(sesiResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Future<Either<String, String>> createSesi(SesiRequestModel request) async {
    try {
      final response = await httpClient.postWithToken(
        "sesi",
        request.toJson(),
      );

      if (response.statusCode == 201) {
        return Right("Olahraga berhasil ditambahkan");
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal menambahkan sesi olahraga');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Future<Either<String, String>> updateSesi(
    int id,
    SesiRequestModel request,
  ) async {
    try {
      final response = await httpClient.put(
        "sesi/$id",
        request.toJson(),
      );

      if (response.statusCode == 200) {
        return Right("Olahraga berhasil diubah");
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal mengubah sesi');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Future<Either<String, String>> deleteSesi(int id) async {
    try {
      final response = await httpClient.delete(
        "sesi/$id",
      );

      if (response.statusCode == 200) {
        return Right("Olahraga berhasil dihapus");
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal menghapus sesi');
      }
    } catch (e) {
      return Left("Terjadi kesalahan: $e");
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
