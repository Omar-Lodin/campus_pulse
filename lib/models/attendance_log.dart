class AttendanceLog {
  final int? id;
  final int eventID;
  final String status;
  final String personalNote;

  AttendanceLog({
    this.id,
    required this.eventID,
    required this. status,
    this.personalNote = '',
  });

  //converts AttendanceLog model into map for db
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id' : id,
      'eventID': eventID,
      'status': status,
      'personalNote': personalNote.trim(),
    };
  }

  //convert database map into attendance log entry
  static AttendanceLog fromMap(Map<String, Object?> map) {
    return AttendanceLog(
      id: map['id'] as int,
      eventID: map['eventID'] as int,
      status: map['status'] as String,
      personalNote: map['personalNote'] as String,
    );
  }
}