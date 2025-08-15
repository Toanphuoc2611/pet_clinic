import 'package:bloc/bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';

class KennelDetailBloc extends Bloc<KennelDetailEvent, KennelDetailState> {
  final KennelDetailRepository kennelDetailRepository;
  KennelDetailBloc(this.kennelDetailRepository)
    : super(KennelDetailGetInitial()) {
    on<BookKennelDetailStarted>(_onBookKennelDetailStarted);
    on<KennelDetailGetStarted>(_onGetKennelDetailStarted);
    on<KennelDetailCancelStarted>(_onCancelKennelDetailStarted);
  }

  void _onBookKennelDetailStarted(
    BookKennelDetailStarted event,
    Emitter<KennelDetailState> emit,
  ) async {
    emit(BookKennelDetailInProgress());
    final result = await kennelDetailRepository.bookKennnel(event.request);

    return (switch (result) {
      Success() => emit(BookKennelDetailSuccess()),
      Failure() => emit(BookKennelDetailFailure(result.message)),
    });
  }

  void _onGetKennelDetailStarted(
    KennelDetailGetStarted event,
    Emitter<KennelDetailState> emit,
  ) async {
    emit(KennelDetailGetInProgress());
    final result = await kennelDetailRepository.getAllKennelByUser();
    return (switch (result) {
      Success() => emit(KennelDetailGetSuccess(result.data)),
      Failure() => emit(KennelDetailGetFailure(result.message)),
    });
  }

  void _onCancelKennelDetailStarted(
    KennelDetailCancelStarted event,
    Emitter<KennelDetailState> emit,
  ) async {
    emit(KennelDetailCancelInProgress());
    final result = await kennelDetailRepository.cancelBookKennel(event.id);
    return (switch (result) {
      Success() => emit(KennelDetailCancelSuccess(result.data)),
      Failure() => emit(KennelDetailCancelFailure(result.message)),
    });
  }
}
