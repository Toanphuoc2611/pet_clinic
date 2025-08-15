import 'package:ung_dung_thu_y/dto/pet/pet_update_avatar.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_avatar.dart';

sealed class UploadAvatarEvent {}

class UploadAvatarPetStarted extends UploadAvatarEvent {
  final PetUpdateAvatar petUpdateAvatar;
  UploadAvatarPetStarted(this.petUpdateAvatar);
}

class UploadAvatarUserStarted extends UploadAvatarEvent {
  final UserUpdateAvatar user;
  UploadAvatarUserStarted(this.user);
}
