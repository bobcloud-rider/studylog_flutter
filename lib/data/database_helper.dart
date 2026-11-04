import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final filePath = join(await getDatabasesPath(), "studylog.db");
    _database = await openDatabase(
      filePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE catatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mata_kuliah TEXT NOT NULL,
            judul TEXT NOT NULL,
            isi TEXT NOT NULL,
            tanggal TEXT NOT NULL
          )
        """);
      },
    );
    return _database!;
  }
}
