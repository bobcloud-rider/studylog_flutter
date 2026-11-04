import "package:flutter_test/flutter_test.dart";
import "package:studylog_flutter/models/catatan.dart";

void main() {
  test("Catatan round-trip Map tidak mengubah data", () {
    final asli = Catatan(
      id: 10,
      mataKuliah: "Pemrograman Mobile",
      judul: "SQLite",
      isi: "Materi CRUD",
      tanggal: DateTime(2026, 10, 22),
    );
    final hasil = Catatan.fromMap(asli.toMap());
    expect(hasil.id, 10);
    expect(hasil.judul, "SQLite");
    expect(hasil.mataKuliah, "Pemrograman Mobile");
    expect(hasil.isi, "Materi CRUD");
  });
}
