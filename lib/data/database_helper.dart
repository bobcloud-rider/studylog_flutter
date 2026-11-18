import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

/// Satu database untuk SELURUH aplikasi (StudyLog + Campus Report).
///
/// Versi 1: tabel `catatan`   (Praktikum 3)
/// Versi 2: tabel `laporan`   (modul Campus Report / aduan fasilitas)
///
/// `onUpgrade` ditulis idempoten (IF NOT EXISTS) supaya aman ketika pengguna
/// sudah punya database versi 1 di HP dan aplikasi diperbarui.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String tabelCatatan = "catatan";
  static const String tabelLaporan = "laporan";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final filePath = join(await getDatabasesPath(), "studylog.db");
    _database = await openDatabase(
      filePath,
      version: 2,
      onCreate: (db, version) async {
        await _buatTabelCatatan(db);
        await _buatTabelLaporan(db);
      },
      onUpgrade: (db, lama, baru) async {
        if (lama < 2) {
          // Pengguna lama: cukup tambahkan tabel laporan, data catatan aman.
          await _buatTabelLaporan(db);
        }
      },
    );
    return _database!;
  }

  // ---------- Praktikum 3: catatan kuliah ----------
  Future<void> _buatTabelCatatan(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tabelCatatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mata_kuliah TEXT NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        tanggal TEXT NOT NULL
      )
    ''');
  }

  // ---------- Campus Report: aduan fasilitas ----------
  Future<void> _buatTabelLaporan(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tabelLaporan (
        local_id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        kategori TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        prioritas TEXT NOT NULL,
        dibuat_pada TEXT NOT NULL,
        photo_path TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT NOT NULL,
        server_id INTEGER,
        last_error TEXT
      )
    ''');
    await db.execute(
        "CREATE INDEX IF NOT EXISTS idx_laporan_status ON $tabelLaporan(status)");
  }

  /// Dipakai untuk reset demo / test.
  Future<void> tutup() async {
    await _database?.close();
    _database = null;
  }
}
