import "package:flutter_test/flutter_test.dart";

// Nama paket proyek: studylog_flutter.
import "package:studylog_flutter/models/catatan.dart";
import "package:studylog_flutter/screens/daftar_catatan_page.dart";

/// Pengujian US-03 — pencarian berdasarkan judul.
/// Tidak butuh database maupun HP: fungsinya murni (input -> output).
void main() {
  Catatan buat(String mk, String judul) => Catatan(
        mataKuliah: mk,
        judul: judul,
        isi: "isi dari $judul",
        tanggal: DateTime(2026, 1, 1),
      );

  final data = <Catatan>[
    buat("Pemrograman Aplikasi Bergerak", "Tugas Mandiri 1 — State & Events"),
    buat("Pemrograman Aplikasi Bergerak", "Tugas -1"),
    buat("Sistem Manajemen Basis Data", "Normalisasi dan Relasi"),
    buat("Sistem Manajemen Basis Data", "Tugas SQL JOIN"),
  ];

  test("kata kunci kosong mengembalikan semua catatan", () {
    expect(cariCatatanByJudul(data, "").length, 4);
    expect(cariCatatanByJudul(data, "   ").length, 4);
  });

  test("mencocokkan sebagian judul", () {
    final hasil = cariCatatanByJudul(data, "tugas");
    expect(hasil.length, 3);
    expect(hasil.map((c) => c.judul), contains("Tugas -1"));
    expect(hasil.map((c) => c.judul), contains("Tugas SQL JOIN"));
    expect(hasil.map((c) => c.judul), contains("Tugas Mandiri 1 — State & Events"));
  });

  test("tidak peka huruf besar/kecil", () {
    expect(cariCatatanByJudul(data, "TUGAS").length, 3);
    expect(cariCatatanByJudul(data, "TuGaS").length, 3);
    expect(cariCatatanByJudul(data, "normalisasi").single.judul,
        "Normalisasi dan Relasi");
    expect(cariCatatanByJudul(data, "NORMALISASI").single.judul,
        "Normalisasi dan Relasi");
  });

  test("spasi di awal dan akhir diabaikan", () {
    expect(cariCatatanByJudul(data, "  sql  ").single.judul, "Tugas SQL JOIN");
  });

  test("kata kunci tidak ditemukan menghasilkan daftar kosong", () {
    expect(cariCatatanByJudul(data, "kalkulus").isEmpty, isTrue);
    expect(cariCatatanByJudul(data, "zzz").isEmpty, isTrue);
  });

  test("hanya mencari di judul, bukan di isi catatan", () {
    // semua isi berawalan "isi dari ...", tapi kata "isi" tidak ada di judul
    expect(cariCatatanByJudul(data, "isi").isEmpty, isTrue);
  });

  test("hasil pencarian tetap dikelompokkan per mata kuliah", () {
    final hasil = cariCatatanByJudul(data, "tugas");
    final kelompok = kelompokByMK(hasil, null);
    // urutan mengikuti daftar mata kuliah, jadi diperiksa sebagai himpunan
    expect(kelompok.map((e) => e.key).toSet(),
        {"Pemrograman Aplikasi Bergerak", "Sistem Manajemen Basis Data"});
    expect(kelompok.expand((e) => e.value).length, 3);
  });

  test("pencarian digabung filter mata kuliah", () {
    final hasil = cariCatatanByJudul(data, "tugas");
    final smbd = kelompokByMK(hasil, "Sistem Manajemen Basis Data");
    expect(smbd.length, 1);
    expect(smbd.single.value.single.judul, "Tugas SQL JOIN");
  });
}
