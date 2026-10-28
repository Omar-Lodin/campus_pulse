import 'dart:convert';

class Event {
  final int? id;
  final String title;
  final DateTime eventDateTime;
  final List<String> tags;
  final String location;
  final int? capacity;

  Event({
    this.id,
    required this.title,
    required this.eventDateTime,
    required this.tags,
    this.location = '',
    this.capacity,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title.trim(),
      'eventDateTime': eventDateTime.toIso8601String(),
      'tags': jsonEncode(tags),
      'location': location.trim(),
      'capacity': capacity,
    };
  }
}
