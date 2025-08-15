import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet_search/pet_search_event.dart';
import 'package:ung_dung_thu_y/bloc/pet_search/pet_search_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';

class PetSearchBloc extends Bloc<PetSearchEvent, PetSearchState> {
  PetSearchBloc(this.petRepository) : super(PetSearchInitial()) {
    on<PetSearchStarted>(_onSearchStarted);
  }
  final PetRepository petRepository;

  void _onSearchStarted(
    PetSearchStarted event,
    Emitter<PetSearchState> emit,
  ) async {
    emit(PetSearchInProgress());
    final result = await petRepository.searchByName(event.content);
    return (switch (result) {
      Success() => emit(PetSearchSuccess(result.data)),
      Failure() => emit(PetSearchFailure(result.message)),
    });
  }
}
