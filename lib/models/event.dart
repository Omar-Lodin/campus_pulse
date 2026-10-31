
class CampusEvent {
  int? id;
  String name;
  String description;
  String location;
  String category;
  DateTime date;
  String notes;
  final int? capacity;

  CampusEvent({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    required this.date,
    this.notes = '',
    this.capacity,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
      'capacity': capacity,
    };
  }

  static CampusEvent fromMap(Map<String, Object?> map) {
    return CampusEvent(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String? ?? '',
      capacity: map['capacity'] as int?,
    );
  }
}
