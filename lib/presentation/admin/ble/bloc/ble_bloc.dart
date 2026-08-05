import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:blueattend/data/model/request/ble/ble_request_model.dart';
import 'package:blueattend/data/model/response/get_all_ble_response_model.dart';
import 'package:blueattend/data/repository/ble_repository.dart';

part 'ble_event.dart';
part 'ble_state.dart';


class BleBloc extends Bloc<BleEvent, BleState> {
  final BleRepository bleRepository;

  BleBloc({required this.bleRepository}) : super(BleInitial()) {
    on<BleRequested>(_onBleRequested);
    on<BleCreateRequested>(_onBleCreateRequested);
    on<BleUpdateRequested>(_onBleUpdateRequested);
    on<BleDeleted>(_onBleDeleted);
  }

  Future<void> _onBleRequested(
    BleRequested event,
    Emitter<BleState> emit,
  ) async {
    emit(BleLoading());

    final result = await bleRepository.getAllBle();

    result.fold(
      (error) => emit(BleLoadFailure(error: error)),
      (data) => emit(BleLoaded(listBle: data.dataBle)),
    );
  }

  Future<void> _onBleCreateRequested(
    BleCreateRequested event,
    Emitter<BleState> emit,
  ) async {
    final result = await bleRepository.createBle(event.requestModel);

    await result.fold(
      (error) async {
        emit(BleActionFailure(error: error));
      },
      (message) async {
        emit(BleOperationSuccess(message: message));
      },
    );

    final refresh = await bleRepository.getAllBle();
    refresh.fold(
      (error) => emit(BleLoadFailure(error: error)),
      (data) => emit(BleLoaded(listBle: data.dataBle)),
    );
  }

  Future<void> _onBleUpdateRequested(
    BleUpdateRequested event,
    Emitter<BleState> emit,
  ) async {
    final result = await bleRepository.updateBle(
      event.id,
      event.requestModel,
    );

    await result.fold(
      (error) async => emit(BleActionFailure(error: error)),
      (message) async => emit(BleOperationSuccess(message: message)),
    );

    final refresh = await bleRepository.getAllBle();
    refresh.fold(
      (error) => emit(BleLoadFailure(error: error)),
      (data) => emit(BleLoaded(listBle: data.dataBle)),
    );
  }

  Future<void> _onBleDeleted(
    BleDeleted event,
    Emitter<BleState> emit,
  ) async {
    final result = await bleRepository.deleteBle(event.id);

    await result.fold(
      (error) async => emit(BleActionFailure(error: error)),
      (message) async => emit(BleOperationSuccess(message: message)),
    );

    final refresh = await bleRepository.getAllBle();
    refresh.fold(
      (error) => emit(BleLoadFailure(error: error)),
      (data) => emit(BleLoaded(listBle: data.dataBle)),
    );
  }
}
