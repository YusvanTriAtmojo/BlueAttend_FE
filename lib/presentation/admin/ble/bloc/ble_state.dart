part of 'ble_bloc.dart';

@immutable
sealed class BleState {}

final class BleInitial extends BleState {}

final class BleLoading extends BleState {}

final class BleLoaded extends BleState {
  final List<Ble> listBle;

  BleLoaded({required this.listBle});
}

final class BleOperationSuccess extends BleState {
  final String message;

  BleOperationSuccess({required this.message});
}

final class BleLoadFailure extends BleState {
  final String error;
  BleLoadFailure({required this.error});
}

final class BleActionFailure extends BleState {
  final String error;
  BleActionFailure({required this.error});
}

