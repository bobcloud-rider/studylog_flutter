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

  group("kelompokByMK - cari berdasarkan judul (US-03)", () {
    test("pencarian tidak peka huruf besar/kecil", () {
      for (final kata in ["kuis", "KUIS", "KuIs"]) {
        final hasil = kelompokByMK(data, null, kataKunci: kata);
        expect(hasil.length, 1);
        expect(hasil.single.key, "Kriptografi");
        expect(hasil.single.value.map((c) => c.judul), ["Kuis 1", "Kuis 2"]);
      }
    });

    test("kata kunci cocok sebagian dan lintas mata kuliah", () {
      final hasil = kelompokByMK(data, null, kataKunci: "2");
      final kunci = hasil.map((e) => e.key).toList();
      expect(kunci, ["Robotika", "Kriptografi"]);
      expect(hasil.every((e) => e.value.length == 1), isTrue);
    });

    test("pencarian bisa digabung dengan filter mata kuliah", () {
      final hasil = kelompokByMK(data, "Kriptografi", kataKunci: "2");
      expect(hasil.length, 1);
      expect(hasil.single.key, "Kriptografi");
      expect(hasil.single.value.single.judul, "Kuis 2");
    });

    test("catatan di kelompok Lainnya ikut tercari", () {
      final hasil = kelompokByMK(data, null, kataKunci: "lain");
      expect(hasil.single.key, "Lainnya");
      expect(hasil.single.value.single.judul, "Catatan lain");
    });

    test("kata kunci kosong atau spasi saja = tanpa pencarian", () {
      final tanpa = kelompokByMK(data, null);
      for (final kata in ["", "   "]) {
        final hasil = kelompokByMK(data, null, kataKunci: kata);
        expect(hasil.map((e) => e.key), tanpa.map((e) => e.key));
      }
    });

    test("kata kunci tanpa hasil menghasilkan daftar kosong", () {
      expect(kelompokByMK(data, null, kataKunci: "tidak ada"), isEmpty);
    });

    test("hanya mencari di judul, bukan di isi catatan", () {
      //cuma judul, isi nggak ikut dicari
      expect(kelompokByMK(data, null, kataKunci: "isi"), isEmpty);
    });
  });
}
