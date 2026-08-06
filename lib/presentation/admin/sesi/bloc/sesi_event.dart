part of 'sesi_bloc.dart';

sealed class SesiEvent {}

class SesiRequested extends SesiEvent {}

class SesiCreateRequested extends SesiEvent {
  final SesiRequestModel requestModel;

  SesiCreateRequested({required this.requestModel});
}

final class SesiUpdateRequested extends SesiEvent {
  final int id;
  final SesiRequestModel requestModel;

  SesiUpdateRequested({
    required this.id,
    required this.requestModel,
  });
}

final class SesiDeleted extends SesiEvent {
  final int id;

  SesiDeleted(this.id);
}