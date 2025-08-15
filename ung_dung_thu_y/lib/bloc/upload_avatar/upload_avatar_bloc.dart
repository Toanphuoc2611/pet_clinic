import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_event.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/upload_avatar/upload_avatar_repository.dart';

class UploadAvatarBloc extends Bloc<UploadAvatarEvent, UploadAvatarState> {
  UploadAvatarBloc(this.uploadAvatarRepository) : super(UploadAvatarInitial()) {
    on<UploadAvatarPetStarted>(_onUploadAvatarPetStarted);
    on<UploadAvatarUserStarted>(_onUploadAvatarUserStarted);
  }
  final UploadAvatarRepository uploadAvatarRepository;
  void _onUploadAvatarPetStarted(
    UploadAvatarPetStarted event,
    Emitter<UploadAvatarState> emit,
  ) async {
    emit(UploadAvatarInProgree());
    final result = await uploadAvatarRepository.uploadAvatarPet(
      event.petUpdateAvatar,
    );
    return (switch (result) {
      Success() => emit(UploadAvatarSuccess(result.data)),
      Failure() => emit(UploadAvatarFailure(result.message)),
    });
  }

  void _onUploadAvatarUserStarted(
    UploadAvatarUserStarted event,
    Emitter<UploadAvatarState> emit,
  ) async {
    emit(UploadAvatarInProgree());
    final result = await uploadAvatarRepository.uploadAvatarUser(event.user);
    return (switch (result) {
      Success() => emit(UploadAvatarSuccess(result.data)),
      Failure() => emit(UploadAvatarFailure(result.message)),
    });
  }
}
