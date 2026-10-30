
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'campus_pulse.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            location TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
            attended_date TEXT NOT NULL,
            FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE
          )
        ''');
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    return _database!;
  }

  static Future<List<Map<String, Object?>>> getEvents() async {
    final db = await database;
    return db.query('events', orderBy: 'date ASC');
  }

  static Future<int> addEvent(Map<String, Object?> event) async {
    final db = await database;
    return db.insert('events', event);
  }

  static Future<int> updateEvent(
    int id,
    Map<String, Object?> event,
  ) async {
    final db = await database;

    return db.update(
      'events',
      event,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteEvent(int id) async {
    final db = await database;

    return db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> addAttendance(int eventId) async {
    final db = await database;

    return db.transaction((transaction) async {
      final existing = await transaction.query(
        'attendance', where:'event_id = ?', whereArgs: [eventId], limit: 1,
      );
      if (existing.isNotEmpty) {
        return false;
      }
      await transaction.insert('attendance',{
        'event_id': eventId,
        'attended_date':DateTime.now().toIso8601String(),
      });
      return true;
    });
  }

  static Future<int> deleteAttendance(int id) async {
    final db = await database;

    return db.delete(
      'attendance', where: 'id = ?', whereArgs: [id],
    );
  }

  static Future<List<Map<String, Object?>>> getAttendance() async {
    final db = await database;

    return db.rawQuery('''
      SELECT attendance.id, attendance.event_id,
             attendance.attended_date,
             events.name AS event_name
      FROM attendance
      JOIN events ON attendance.event_id = events.id
      ORDER BY attendance.id DESC
    ''');
  }
}
