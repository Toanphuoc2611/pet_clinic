sealed class UploadAvatarState {}

class UploadAvatarInitial extends UploadAvatarState {}

class UploadAvatarInProgree extends UploadAvatarState {}

class UploadAvatarSuccess extends UploadAvatarState {
  final String url;
  UploadAvatarSuccess(this.url);
}

class UploadAvatarFailure extends UploadAvatarState {
  final String message;
  UploadAvatarFailure(this.message);
}
