import "package:sqflite/sqflite.dart";

import "../models/catatan.dart";
import "database_helper.dart";

class CatatanRepository {
  final DatabaseHelper helper;
  CatatanRepository(this.helper);

  Future<List<Catatan>> semua() async {
    final Database db = await helper.database;
    final baris = await db.query("catatan", orderBy: "tanggal DESC, id DESC");
    return baris.map(Catatan.fromMap).toList();
  }

  Future<int> tambah(Catatan catatan) async {
    final db = await helper.database;
    return db.insert("catatan", catatan.toMap());
  }

  Future<int> ubah(Catatan catatan) async {
    if (catatan.id == null) throw ArgumentError("ID catatan tidak boleh kosong");
    final db = await helper.database;
    return db.update("catatan", catatan.toMap(),
        where: "id = ?", whereArgs: [catatan.id]);
  }

  Future<int> hapus(int id) async {
    final db = await helper.database;
    return db.delete("catatan", where: "id = ?", whereArgs: [id]);
  }
}
