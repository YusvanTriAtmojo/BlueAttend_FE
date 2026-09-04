part of 'presensi_bloc.dart';

sealed class PresensiState {}

final class PresensiInitial extends PresensiState {}

final class PresensiLoading extends PresensiState {}

final class PresensiBleReady extends PresensiState {}

final class PresensiSuccess extends PresensiState {
  final String message;

  PresensiSuccess(this.message);
}

final class PresensiFailure extends PresensiState {
  final String error;

  PresensiFailure(this.error);
}

final class RiwayatPresensiSuccess extends PresensiState {
  final List<dynamic> data;

  RiwayatPresensiSuccess(this.data);
}

final class PresensiMencariPerangkat extends PresensiState {}

final class PresensiPerangkatDitemukan extends PresensiState {}