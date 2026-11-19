import "package:flutter_test/flutter_test.dart";

// Nama paket proyek: studylog_flutter.
import "package:studylog_flutter/models/catatan.dart";
import "package:studylog_flutter/screens/daftar_catatan_page.dart";

/// Pengujian US-05 — mengurutkan daftar catatan.
/// Murni (input -> output), tidak butuh database maupun perangkat.
void main() {
  Catatan buat(String judul, DateTime tanggal) => Catatan(
        mataKuliah: "Pemrograman Aplikasi Bergerak",
        judul: judul,
        isi: "isi $judul",
        tanggal: tanggal,
      );

  final data = <Catatan>[
    buat("Beta", DateTime(2026, 3, 10)),
    buat("alpha", DateTime(2026, 1, 5)),
    buat("Gamma", DateTime(2026, 2, 20)),
    buat("Alpha 2", DateTime(2026, 1, 5)), // tanggal sama dengan "alpha"
  ];

  List<String> judulDari(List<Catatan> l) => l.map((c) => c.judul).toList();

  test("pilihan urutan tersedia empat dan default Terbaru", () {
    expect(pilihanUrutan.length, 4);
    expect(pilihanUrutan.first, "Terbaru");
  });

  test("Terbaru: tanggal terbesar lebih dulu", () {
    final hasil = urutkanCatatan(data, "Terbaru");
    expect(judulDari(hasil), ["Beta", "Gamma", "alpha", "Alpha 2"]);
  });

  test("Terlama: tanggal terkecil lebih dulu", () {
    final hasil = urutkanCatatan(data, "Terlama");
    expect(judulDari(hasil).take(2), ["alpha", "Alpha 2"]);
    expect(judulDari(hasil).last, "Beta");
  });

  test("Judul A–Z tidak peka huruf besar/kecil", () {
    final hasil = urutkanCatatan(data, "Judul A–Z");
    // "alpha" dan "Alpha 2" dianggap berawalan sama, dibandingkan lowercase
    expect(judulDari(hasil).first.toLowerCase(), startsWith("alpha"));
    expect(judulDari(hasil).last, "Gamma");
  });

  test("Judul Z–A adalah kebalikan Judul A–Z", () {
    final naik = judulDari(urutkanCatatan(data, "Judul A–Z"));
    final turun = judulDari(urutkanCatatan(data, "Judul Z–A"));
    expect(turun, naik.reversed.toList());
  });

  test("mode tidak dikenal diperlakukan sebagai Terbaru", () {
    expect(judulDari(urutkanCatatan(data, "acak")),
        judulDari(urutkanCatatan(data, "Terbaru")));
  });

  test("tanggal sama dirapikan dengan judul (hasil konsisten)", () {
    final a = judulDari(urutkanCatatan(data, "Terbaru"));
    final b = judulDari(urutkanCatatan(data, "Terbaru"));
    expect(a, b);
  });

  test("daftar asli tidak ikut berubah (fungsi tidak merusak input)", () {
    final asli = judulDari(data);
    urutkanCatatan(data, "Judul A–Z");
    expect(judulDari(data), asli);
  });

  test("daftar kosong tetap kosong", () {
    expect(urutkanCatatan(<Catatan>[], "Terbaru"), isEmpty);
  });
}
