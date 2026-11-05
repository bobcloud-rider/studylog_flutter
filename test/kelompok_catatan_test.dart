import "package:flutter_test/flutter_test.dart";

// Ganti "studylog" sesuai `name:` pada pubspec.yaml proyek Anda.
import "package:studylog_flutter/models/catatan.dart";
import "package:studylog_flutter/screens/daftar_catatan_page.dart";

void main() {
  Catatan buat(String mk, String judul) => Catatan(
        mataKuliah: mk,
        judul: judul,
        isi: "isi $judul",
        tanggal: DateTime(2026, 1, 1),
      );

  final data = [
    buat("Kriptografi", "Kuis 1"),
    buat("Robotika", "Tugas 2"),
    buat("Kriptografi", "Kuis 2"),
    buat("Mata Kuliah Bebas", "Catatan lain"),
  ];

  group("kelompokByMK", () {
    test("mengelompokkan per mata kuliah sesuai urutan semuaMataKuliah", () {
      final hasil = kelompokByMK(data, null);
      final kunci = hasil.map((e) => e.key).toList();

      // Robotika muncul sebelum Kriptografi (urutan daftar mata kuliah).
      expect(kunci.indexOf("Robotika"), greaterThanOrEqualTo(0));
      expect(kunci.indexOf("Robotika"), lessThan(kunci.indexOf("Kriptografi")));
      // MK di luar daftar tetap ditampilkan sebagai "Lainnya".
      expect(kunci.contains("Lainnya"), isTrue);

      final kripto = hasil.firstWhere((e) => e.key == "Kriptografi");
      expect(kripto.value.length, 2);
    });

    test("filter mata kuliah hanya mengembalikan kelompok yang dipilih", () {
      final hasil = kelompokByMK(data, "Kriptografi");
      expect(hasil.length, 1);
      expect(hasil.single.key, "Kriptografi");
      expect(hasil.single.value.length, 2);
    });

    test("filter mata kuliah tanpa data menghasilkan daftar kosong", () {
      final hasil = kelompokByMK(data, "Jaringan Nirkabel");
      expect(hasil, isEmpty);
    });
  });
}
