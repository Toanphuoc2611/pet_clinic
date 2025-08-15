class PetSearchEvent {}

class PetSearchStarted extends PetSearchEvent {
  final String content;
  PetSearchStarted(this.content);
}
