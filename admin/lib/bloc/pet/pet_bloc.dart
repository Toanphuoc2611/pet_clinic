import 'package:admin/bloc/pet/pet_event.dart';
import 'package:admin/bloc/pet/pet_state.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/repository/pet/pet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  final PetRepository petRepository;

  PetBloc(this.petRepository) : super(PetInitial()) {
    on<PetGetByUserIdStarted>(_onGetByUserIdStarted);
  }

  void _onGetByUserIdStarted(
    PetGetByUserIdStarted event,
    Emitter<PetState> emit,
  ) async {
    emit(PetGetInProgress());
    var result = await petRepository.getPetListByUser(event.userId);
    return (switch (result) {
      Success() => emit(PetGetByUserIdSuccess(result.data)),
      Failure() => emit(PetGetFailure(result.message)),
    });
  }
}
