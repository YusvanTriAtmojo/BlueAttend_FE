part of 'presensi_bloc.dart';

sealed class PresensiEvent {}

final class PastikanBleOn extends PresensiEvent {}

final class RiwayatRequested extends PresensiEvent {}

final class KirimPresensi extends PresensiEvent {
  final String token;
  final File fotoWajah;

  KirimPresensi({
    required this.token,
    required this.fotoWajah,
  });
}

final class PerangkatDitemukan extends PresensiEvent {}