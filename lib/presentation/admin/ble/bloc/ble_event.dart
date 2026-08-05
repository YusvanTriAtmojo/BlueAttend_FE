part of 'ble_bloc.dart';


sealed class BleEvent {}

final class BleRequested extends BleEvent {}

final class BleCreateRequested extends BleEvent {
  final BleRequestModel requestModel;

  BleCreateRequested({required this.requestModel});
}

final class BleUpdateRequested extends BleEvent {
  final int id;
  final BleRequestModel requestModel;

  BleUpdateRequested({
    required this.id,
    required this.requestModel,
  });
}

final class BleDeleted extends BleEvent {
  final int id;

  BleDeleted(this.id);
}