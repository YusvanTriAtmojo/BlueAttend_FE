import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:blueattend/data/repository/presensi_repository.dart';

part 'presensi_event.dart';
part 'presensi_state.dart';

class PresensiBloc extends Bloc<PresensiEvent, PresensiState> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final PresensiRepository presensiRepository;

  PresensiBloc({required this.presensiRepository}) : super(PresensiInitial()) {
    on<PastikanBleOn>(_memastikanBle);
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
}
