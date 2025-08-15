abstract class PetEvent {}

class PetGetByUserIdStarted extends PetEvent {
  final String userId;
  PetGetByUserIdStarted(this.userId);
}
