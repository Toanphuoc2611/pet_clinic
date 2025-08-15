import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_event.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_repository.dart';

class KennelBloc extends Bloc<KennelEvent, KennelState> {
  final KennelRepository kennelRepository;
  KennelBloc(this.kennelRepository) : super(KennelInitial()) {
    on<KennelGetStarted>(_getStarted);
  }

  void _getStarted(KennelGetStarted event, Emitter<KennelState> emit) async {
    emit(KennelGetInProgress());
    final result = await kennelRepository.getKennels();
    return (switch (result) {
      Success() => emit(KennelGetSuccess(result.data)),
      Failure() => emit(KennelGetFailure(result.message)),
    });
  }
}
