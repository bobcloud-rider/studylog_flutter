import "package:sqflite/sqflite.dart";

import "../../data/database_helper.dart";
import "../models/laporan.dart";

/// Laporan aduan fasilitas kampus (modul Campus Report).
///
/// Memakai helper database StudyLog yang sama -> semua konversi baris <-> [Laporan]
/// berada di satu tempat, dan ViewModel tidak pernah menulis SQL.
class LaporanRepository {
  LaporanRepository(this.helper);

  final DatabaseHelper helper;

  Future<List<Laporan>> semua() async {
    final db = await helper.database;
    final baris = await db.query(
      DatabaseHelper.tabelLaporan,
      orderBy: "dibuat_pada DESC",
    );
    return baris.map(Laporan.fromMap).toList();
  }

  Future<Laporan?> cari(String localId) async {
    final db = await helper.database;
    final baris = await db.query(
      DatabaseHelper.tabelLaporan,
      where: "local_id = ?",
      whereArgs: [localId],
      limit: 1,
    );
    if (baris.isEmpty) return null;
    return Laporan.fromMap(baris.first);
  }

  Future<void> tambah(Laporan laporan) async {
    final db = await helper.database;
    await db.insert(
      DatabaseHelper.tabelLaporan,
      laporan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> ubah(Laporan laporan) async {
    final db = await helper.database;
    await db.update(
      DatabaseHelper.tabelLaporan,
      laporan.toMap(),
      where: "local_id = ?",
      whereArgs: [laporan.localId],
    );
  }

  Future<void> hapus(String localId) async {
    final db = await helper.database;
    await db.delete(
      DatabaseHelper.tabelLaporan,
      where: "local_id = ?",
      whereArgs: [localId],
    );
  }

  /// Laporan yang masih SENDING saat aplikasi ditutup/crash -> FAILED
  /// supaya tidak "menggantung" dan bisa di-retry.
  Future<int> tandaiSendingMenjadiGagal() async {
    final db = await helper.database;
    return db.update(
      DatabaseHelper.tabelLaporan,
      {
        "status": StatusKirim.failed.name,
        "last_error":
            "Pengiriman terhenti karena aplikasi ditutup. Tekan Retry.",
      },
      where: "status = ?",
      whereArgs: [StatusKirim.sending.name],
    );
  }

  Future<int> jumlah() async {
    final db = await helper.database;
    final hasil = await db.rawQuery(
        "SELECT COUNT(*) AS jumlah FROM ${DatabaseHelper.tabelLaporan}");
    return (hasil.first["jumlah"] as num?)?.toInt() ?? 0;
  }
}
