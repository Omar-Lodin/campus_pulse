import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static const List<String> eventCategories = [
    'Sports',
    'Movies',
    'Art',
    'Music',
    'Social',
    'Academic',
    'Volunteering',
    'Gaming',
    'Food',
    'Career',
    'Technology',
  ];

  static Future<Database> get database async {
    if (_database != null) return _database!;

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'campus_pulse.db');

    _database = await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            location TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            notes TEXT NOT NULL DEFAULT ''
            capacity INTEGER
            is_planned INTEGER NOT NULL DEFAULT 0
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

      onUpgrade: (db, oldVersion, newVersion) async {
        final columns = await db.rawQuery('PRAGMA table_info(events)');
        final columnNames = columns.map((column) => column['name']).toSet();
        if (oldVersion < 2 && !columnNames.contains('notes')) {
          await db.execute(
            "ALTER TABLE events ADD COLUMN notes TEXT NOT NULL DEFAULT ''",
          );
        }
        if (oldVersion < 3 && !columnNames.contains('capacity')) {
          await db.execute('ALTER TABLE events ADD COLUMN capacity INTEGER');
        }
        if (oldVersion < 4 && !columnNames.contains('is_planned')) {
          await db.execute(
            'ALTER TABLE events ADD COLUMN is_planned INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    return _database!;
  }

  static Future<List<Map<String, Object?>>> getEvents() async {
    final db = await database;
    return db.query(
      'events',
      where: 'id NOT IN (SELECT event_id FROM attendance)',
      orderBy: 'date ASC',
    );
  }

  static Future<int> addEvent(Map<String, Object?> event) async {
    final db = await database;
    return db.insert('events', event);
  }

  static Future<int> updateEvent(int id, Map<String, Object?> event) async {
    final db = await database;

    return db.update('events', event, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteEvent(int id) async {
    final db = await database;

    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> addAttendance(int eventId) async {
    final db = await database;

    return db.transaction((transaction) async {
      final existing = await transaction.query(
        'attendance',
        where: 'event_id = ?',
        whereArgs: [eventId],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        return false;
      }
      await transaction.insert('attendance', {
        'event_id': eventId,
        'attended_date': DateTime.now().toIso8601String(),
      });
      return true;
    });
  }

  static Future<int> deleteAttendance(int id) async {
    final db = await database;

    return db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, Object?>>> getAttendance() async {
    final db = await database;

    return db.query(
      'attendance JOIN events ON attendance.event_id = events.id',
      columns: [
        'attendance.id',
        'attendance.event_id',
        'attendance.attended_date',
        'events.name AS event_name',
        'events.date AS event_date',
      ],
      orderBy: 'attendance.id DESC',
    );
  }

  static Future<Map<String, Object?>?> getEventById(int id) async {
    final db = await database;

    final results = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  static Future<int> getAttendanceCount() async {
    final db = await database;

    final results = await db.query(
      'attendance',
      columns: ['COUNT(*) AS total'],
    );
    return results.first['total'] as int;
  }

  static Future<int> setEventPlanned(int eventId, bool planned) async {
    final db = await database;

    return db.update(
      'events',
      {'is_planned': planned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }
}
