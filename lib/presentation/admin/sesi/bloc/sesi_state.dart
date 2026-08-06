part of 'sesi_bloc.dart';

@immutable
sealed class SesiState {}

final class SesiInitial extends SesiState {}

final class SesiLoading extends SesiState {}

final class SesiLoaded extends SesiState {
  final List<Sesi> listSesi;

  SesiLoaded({required this.listSesi});
}

final class SesiOperationSuccess extends SesiState {
  final String message;

  SesiOperationSuccess({required this.message});
}

final class SesiFailure extends SesiState {
  final String error;

  SesiFailure({required this.error});
}

final class SesiLoadFailure extends SesiState {
  final String error;
  SesiLoadFailure({required this.error});
}

final class SesiActionFailure extends SesiState {
  final String error;
  SesiActionFailure({required this.error});
}

