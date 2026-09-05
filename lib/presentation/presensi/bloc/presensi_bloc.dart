import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:blueattend/service/service_mobile_face_net.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:blueattend/data/model/request/presensi/presensi_request_model.dart';
import 'package:blueattend/data/repository/presensi_repository.dart';

part 'presensi_event.dart';
part 'presensi_state.dart';

class PresensiBloc extends Bloc<PresensiEvent, PresensiState> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final PresensiRepository presensiRepository;
  final ServiceMobileFaceNet _faceNet = ServiceMobileFaceNet();

  PresensiBloc({required this.presensiRepository}) : super(PresensiInitial()) {
    on<PastikanBleOn>(_memastikanBle);
    on<KirimPresensi>(_kirimPresensi);
    on<RiwayatRequested>(_riwayatPresensi);
  }

  Future<void> _memastikanBle(
    PastikanBleOn event,
    Emitter<PresensiState> emit,
  ) async {
    emit(PresensiLoading());

    await [Permission.bluetoothScan, Permission.bluetoothConnect].request();

    final adapterState = await FlutterBluePlus.adapterState.first;

    if (adapterState != BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.turnOn();
        await FlutterBluePlus.adapterState
            .where((s) => s == BluetoothAdapterState.on)
            .first;
      } catch (_) {
        emit(PresensiFailure("Bluetooth diperlukan untuk presensi"));
        return;
      }
    }

    emit(PresensiBleReady());
  }

  Future<void> _riwayatPresensi(
    RiwayatRequested event,
    Emitter<PresensiState> emit,
  ) async {
    emit(PresensiLoading());

    final result = await presensiRepository.cekRiwayatPresensi();

    result.fold(
      (error) => emit(PresensiFailure(error)),
      (data) => emit(RiwayatPresensiSuccess(data.data)),
    );
  }

  Future<void> _kirimPresensi(
    KirimPresensi event,
    Emitter<PresensiState> emit,
  ) async {
    emit(PresensiLoading());

    String? idUser;
    StreamSubscription? scanSubscription;
    Timer? stopTimer;

    final completer = Completer<void>();

    final Map<String, List<int>> uuidRssiSample = {};
    final Map<String, int> rataRataRssi = {};
    final Map<String, String> uuidData = {};
    const int maxUUIDs = 3;
    const String prefix = "19121981";

    bool perangkatDitemukan = false;

    try {
      // mengambil user id
      idUser = await storage.read(key: "userId");

      if (idUser == null || idUser.isEmpty) {
        emit(PresensiFailure("ID User tidak ditemukan"));
        return;
      }

      // inisilasisasi model mobilefacenet
      await _faceNet.initialize();

      // SCAN BLE
      emit(PresensiMencariPerangkat());

      scanSubscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          for (final result in results) {
            final int rssi = result.rssi;

            // mengambil service data kunci ble
            result.advertisementData.serviceData.forEach((uuid, value) {
              final key = String.fromCharCodes(value);

              uuidData[uuid.toString()] = key;
            });

            // proses service UUID
            for (final serviceUuid in result.advertisementData.serviceUuids) {
              final uuidStr = serviceUuid.toString();

              // Filter UUID berdasarkan prefix
              if (!uuidStr.startsWith(prefix)) {
                continue;
              }

              // perangkat ditemukan
              if (!perangkatDitemukan) {
                perangkatDitemukan = true;
                stopTimer = Timer(const Duration(seconds: 2), () {
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                });
              }

              // membatasi maksimal 10 UUID yg dicari
              if (!uuidRssiSample.containsKey(uuidStr)) {
                if (uuidRssiSample.length >= maxUUIDs) {
                  continue;
                }
                uuidRssiSample[uuidStr] = [];
              }

              final samples = uuidRssiSample[uuidStr]!;
              if (samples.length >= 10) {
                samples.removeAt(0);
              }
              samples.add(rssi);
            }
          }
        },
      );

      // memulai SCAN BLE
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        continuousUpdates: true,
      );

      // menunggu SCAN
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );

      if (perangkatDitemukan) {
        emit(PresensiPerangkatDitemukan());
      }
    } catch (e) {
      final error = e.toString().toLowerCase();

      if (error.contains("location services")) {
        emit(PresensiFailure("Aktifkan lokasi untuk menggunakan BLE"));
      } else {
        emit(PresensiFailure("Gagal scan perangkat BLE: $e"));
      }

      return;
    } finally {
      stopTimer?.cancel();

      await scanSubscription?.cancel();

      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }

    // menghitung rata-rata RSSI
    for (final entry in uuidRssiSample.entries) {
      final samples = entry.value;
      if (samples.length < 10) {
        continue;
      }
      final avgRssi = samples.reduce((a, b) => a + b) ~/ samples.length;
      rataRataRssi[entry.key] = avgRssi;
    }

    // jika tidak ada BLE
    if (rataRataRssi.isEmpty) {
      emit(PresensiFailure("Perangkat presensi tidak ditemukan"));
      return;
    }

    // mengurutkan RSSI terkuat
    final sortedUUID =
        rataRataRssi.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final uuidList =
        sortedUUID.map((entry) => entry.key).take(maxUUIDs).toList();

    // generate embedding muka
    List<double> embedding;
    try {
      embedding = await _faceNet.generateEmbedding(event.fotoWajah);
    } catch (e) {
      emit(PresensiFailure("Gagal memproses wajah: $e"));
      return;
    }


    // mengirim ke Backend
    bool success = false;
    String? lastError;

    for (final ble in uuidList) {
      try {
        final key = uuidData[ble];

        if (key == null || key.isEmpty) {
          continue;
        }

        final request = PresensiRequestModel(
          idUser: idUser,
          serviceUuid: [ble],
          token: event.token,
          area: rataRataRssi[ble].toString(),
          data: key,
          faceEmbedding: embedding,
        );

        final result = await presensiRepository
            .createPresensi(request)
            .timeout(const Duration(seconds: 30));

        result.fold(
          (error) {
            final errorLower = error.toLowerCase();

            if (errorLower.contains("socket") ||
                errorLower.contains("connection") ||
                errorLower.contains("internet") ||
                errorLower.contains("network")) {
              lastError = "Periksa koneksi internet Anda";
            } else {
              lastError = error;
            }
          },
          (data) {
            success = true;
            emit(PresensiSuccess(data));
          },
        );

        if (success) {
          break;
        }
      } on TimeoutException {
        lastError = "Waktu koneksi habis, periksa koneksi internet Anda";
      } catch (e) {
        lastError = "Gagal melakukan presensi: $e";
      }
    }
    
    if (!success) {
      emit(PresensiFailure(lastError ?? "Presensi gagal"));
    }
  }
}
