import 'package:festival_pocket/models/attendance_log.dart';
import 'package:festival_pocket/models/event.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class dbHelper {
  static Database? _database;
  static Future<Database> _getDatabase() async {
    final existingDb = _database;
    if (existingDb != null) return existingDb;

    final directory = await getDatabasesPath();
    final pathForDb = join(directory, 'festival_pocket.db');
  

  final db = await openDatabase(
      pathForDb,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE event (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title VARCHAR(50) NOT NULL,
  eventDateTime TEXT NOT NULL,  
  tags TEXT NOT NULL,
  location TEXT NOT NULL DEFAULT '',
  capacity INT CHECK (capacity IS NULL OR capacity > 0)
  )
''');
        await db.execute('''
CREATE TABLE attendance_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  eventID INTEGER NOT NULL UNIQUE,
  status TEXT NOT NULL
    CHECK(status IN ('planned', 'attended', 'cancelled')),
  personalNote TEXT NOT NULL DEFAULT '',
  FOREIGN KEY (eventID) REFERENCES event(id) ON DELETE CASCADE
  )
''');
}
  );
      _database = db;
    return db;
}
//CRUD operations for Event table
static Future<List<Event>> getEvents() async{
    final db = await _getDatabase();
    final result = await db.query('event');
    return result.map((row) => Event.fromMap(row)).toList();
  }

  static Future<int> addEvent(Event event) async {
    final db = await _getDatabase();
    return db.insert('event', event.toMap()..remove('id'));
  }

  static Future<int> updateEvent(Event event) async {
    final db = await _getDatabase();
    return await db.update('event', event.toMap(), where: 'id = ?', whereArgs: [event.id],);
  }

  static Future<int> deleteEvent(int id) async {
    final db = await _getDatabase();
    return await db.delete('event', where: 'id = ?', whereArgs: [id]);
  }

  //CRUD operations for AttendanceLog
  static Future<List<AttendanceLog>> getAttendanceLog() async {
    final db = await _getDatabase();
    final result = await db.query('attendance_log');
    return result.map((row) => AttendanceLog.fromMap(row)).toList();
  }

  static Future<int> addAttendanceLog(AttendanceLog log) async {
    final db = await _getDatabase();
    return db.insert('attendance_log', log.toMap()..remove('id'));
  }

  static Future<int> updateAttendanceLog(AttendanceLog log) async {
    final db = await _getDatabase();
    return await db.update('attendance_log', log.toMap(), where: 'id = ?', whereArgs: [log.id],
    );
  }

  static Future<int> deleteAttendanceLog(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      'attendance_log', where: 'id = ?', whereArgs: [id]
    );
  }
}

