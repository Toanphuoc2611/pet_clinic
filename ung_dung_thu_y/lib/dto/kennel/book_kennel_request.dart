class BookKennelRequest {
  final String inTime;
  final String outTime;
  final String? note;
  final String doctorId;
  final String petId;
  int kennelId;

  BookKennelRequest(
    this.inTime,
    this.outTime,
    this.note,
    this.doctorId,
    this.petId,
    this.kennelId,
  );

  Map<String, dynamic> toJson() => {
    'inTime': inTime,
    'outTime': outTime,
    'note': note ?? "",
    'doctorId': doctorId,
    'petId': petId,
    'kennelId': kennelId,
  };
}
