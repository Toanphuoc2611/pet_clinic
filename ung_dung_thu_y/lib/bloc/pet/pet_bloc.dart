import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_event.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_state.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  PetBloc(this.petRepository) : super(PetAddInititial()) {
    on<PetAddPrepare>(_onAddPrepare);
    on<PetAddStarted>(_onAddStarted);
    on<PetGetStarted>(_onGetStarted);
    on<PetDeleteStarted>(_onDeleteStarted);
    on<PetUpdateStarted>(_onUpdateStarted);
    on<PetGetByUserIdStarted>(_onGetByUserIdStarted);
    on<PetGetKennelValidStarted>(_onGetKennelValidStarted);
  }
  final PetRepository petRepository;

  void _onAddStarted(PetAddStarted event, Emitter<PetState> emit) async {
    emit(PetAddInProgress());
    final result = await petRepository.createPet(event.petAddDto);
    return (switch (result) {
      Success() => emit(PetAddSuccess()),
      Failure() => emit(PetAddFailure(result.message)),
    });
  }

  void _onGetStarted(PetGetStarted event, Emitter<PetState> emit) async {
    emit(PetGetInProgress());
    final result = await petRepository.getPets();
    return (switch (result) {
      Success() => emit(PetGetSuccess(result.data)),
      Failure() => emit(PetGetFailure(result.message)),
    });
  }

  void _onAddPrepare(PetAddPrepare event, Emitter<PetState> emit) {
    emit(PetAddInititial());
  }

  void _onDeleteStarted(PetDeleteStarted event, Emitter<PetState> emit) async {
    emit(PetDeleteInProgress());
    final result = await petRepository.deletePet(event.petId);
    return (switch (result) {
      Success() => emit(PetDeleteSuccess(result.data)),
      Failure() => emit(PetDeleteFailure(result.message)),
    });
  }

  void _onUpdateStarted(PetUpdateStarted event, Emitter<PetState> emit) async {
    emit(PetUpdateInProgress());
    final result = await petRepository.updatePet(
      event.petId,
      event.petUpdateDto,
    );
    return (switch (result) {
      Success() => emit(PetUpdateSuccess(result.data)),
      Failure() => emit(PetUpdateFailure(result.message)),
    });
  }

  void _onGetByUserIdStarted(
    PetGetByUserIdStarted event,
    Emitter<PetState> emit,
  ) async {
    emit(PetGetInProgress());
    final result = await petRepository.getPetsByUserId(event.userId);
    return (switch (result) {
      Success() => emit(PetGetByUserIdSuccess(result.data)),
      Failure() => emit(PetGetByUserIdFailure(result.message)),
    });
  }

  void _onGetKennelValidStarted(
    PetGetKennelValidStarted event,
    Emitter<PetState> emit,
  ) async {
    emit(PetGetKennelValidInProgress());
    final result = await petRepository.getPetsKennelValid();
    return (switch (result) {
      Success() => emit(PetGetKennelValidSuccess(result.data)),
      Failure() => emit(PetGetKennelValidFailure(result.message)),
    });
  }
}
