import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:blueattend/data/model/request/sesi/sesi_request_model.dart';
import 'package:blueattend/data/model/response/get_all_sesi_response_model.dart';
import 'package:blueattend/data/repository/sesi_repository.dart';

part 'sesi_event.dart';
part 'sesi_state.dart';

class SesiBloc extends Bloc<SesiEvent, SesiState> {
 final SesiRepository sesiRepository;

  SesiBloc({required this.sesiRepository}) : super(SesiInitial()) {
    on<SesiRequested>(_onSesiRequested);
    on<SesiCreateRequested>(_onSesiCreateRequested);
    on<SesiUpdateRequested>(_onSesiUpdateRequested);
    on<SesiDeleted>(_onSesiDeleted);
  }

  Future<void> _onSesiRequested(
    SesiRequested event,
    Emitter<SesiState> emit,
  ) async {
    emit(SesiLoading());

    final Either<String, GetAllSesiResponseModel> result =
        await sesiRepository.getAllSesi();

    result.fold(
      (failure) => emit(SesiFailure(error: failure)),
      (data) => emit(SesiLoaded(listSesi: data.data)),
    );
  }

  Future<void> _onSesiCreateRequested(
    SesiCreateRequested event,
    Emitter<SesiState> emit,
  ) async {
    emit(SesiLoading());

    final result = await sesiRepository.createSesi(event.requestModel);

    await result.fold(
      (error) async {
        emit(SesiFailure(error: error));
        final refresh = await sesiRepository.getAllSesi();
        refresh.fold(
          (error) => emit(SesiFailure(error: error)),
          (data) => emit(SesiLoaded(listSesi: data.data)),
        );
      },
      (message) async {
        emit(SesiOperationSuccess(message: message));
        final refresh = await sesiRepository.getAllSesi();
        refresh.fold(
          (error) => emit(SesiFailure(error: error)),
          (data) => emit(SesiLoaded(listSesi: data.data)),
        );
      },
    );
  }

  Future<void> _onSesiUpdateRequested(
    SesiUpdateRequested event,
    Emitter<SesiState> emit,
  ) async {
    final result = await sesiRepository.updateSesi(
      event.id,
      event.requestModel,
    );

    await result.fold(
      (error) async {
        emit(SesiFailure(error: error));
        final refresh = await sesiRepository.getAllSesi();
        refresh.fold(
          (error) => emit(SesiFailure(error: error)),
          (data) => emit(SesiLoaded(listSesi: data.data)),
        );
      },
      (message) async {
        emit(SesiOperationSuccess(message: message));
        final refresh = await sesiRepository.getAllSesi();
        refresh.fold(
          (error) => emit(SesiFailure(error: error)),
          (data) => emit(SesiLoaded(listSesi: data.data)),
        );
      },
    );
  }

  Future<void> _onSesiDeleted(
    SesiDeleted event,
    Emitter<SesiState> emit,
  ) async {
    final result = await sesiRepository.deleteSesi(event.id);

    await result.fold(
      (error) async => emit(SesiActionFailure(error: error)),
      (message) async => emit(SesiOperationSuccess(message: message)),
    );

    final refresh = await sesiRepository.getAllSesi();
    refresh.fold(
      (error) => emit(SesiLoadFailure(error: error)),
      (data) => emit(SesiLoaded(listSesi: data.data)),
    );
  }

}
