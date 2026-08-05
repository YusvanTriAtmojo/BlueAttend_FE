import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:blueattend/data/model/request/ble/ble_request_model.dart';
import 'package:blueattend/data/model/response/get_all_ble_response_model.dart';
import 'package:blueattend/service/service_http_client.dart';

class BleRepository {
  final ServiceHttpClient httpClient;

  BleRepository(this.httpClient);

  Future<Either<String, GetAllBleResponseModel>> getAllBle() async {
    try {
      final response = await httpClient.get("ble");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final bleResponse = GetAllBleResponseModel.fromJson(jsonResponse);
        return Right(bleResponse);
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Future<Either<String, String>> createBle(BleRequestModel request) async {
    try {
      final response = await httpClient.postWithToken(
        "ble",
        request.toJson(),
      );

      if (response.statusCode == 201) {
        return Right("Ble berhasil ditambahkan");
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal menambahkan kategori');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Future<Either<String, String>> updateBle(
    int id,
    BleRequestModel request,
  ) async {
    try {
      final response = await httpClient.put(
        "ble/$id",
        request.toJson(),
      );

      if (response.statusCode == 200) {
        return Right("Ble berhasil diubah");
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal mengubah kategori');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Future<Either<String, String>> deleteBle(int id) async {
    try {
      final response = await httpClient.delete(
        "ble/$id",
      );

      if (response.statusCode == 200) {
        return Right("Ble berhasil dihapus");
      } else {
        final errorMessage = json.decode(response.body);
        return Left(errorMessage['message'] ?? 'Gagal menghapus Ble');
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
