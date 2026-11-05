import "package:flutter/material.dart";

class MataKuliah {
  final String kode;
  final String nama;
  final int sks;
  final Color warna;
  const MataKuliah(this.kode, this.nama, this.sks, this.warna);
}

/// Data mata kuliah pengguna (Semester Ganjil 2026, kelas IFB5A).
const List<MataKuliah> semuaMataKuliah = [
  MataKuliah("111500", "Sistem Manajemen Basis Data", 3,
      Color(0xFF00897B)), // teal
  MataKuliah("111400", "Simulasi dan Game Komputer", 3,
      Color(0xFF1E88E5)), // biru
  MataKuliah("111600", "Teknologi Aplikasi Bergerak", 3,
      Color(0xFF3949AB)), // indigo
  MataKuliah("111100", "Penalaran Komputer", 3, Color(0xFF8E24AA)), // ungu
  MataKuliah("110600", "Jaringan Nirkabel", 3,
      Color(0xFFD81B60)), // pink
  MataKuliah("", "Robotika", 3, Color(0xFFFB8C00)), // oranye
  MataKuliah("111000", "Pemrograman Aplikasi Bergerak", 3,
      Color(0xFF43A047)), // hijau
  MataKuliah("000800", "Penulisan dan Publikasi Ilmiah", 2,
      Color(0xFFF9A825)), // kuning
  MataKuliah("110700", "Kriptografi", 3, Color(0xFFE53935)), // merah
];

/// Warna tetap untuk mata kuliah yang terdaftar; untuk nama lain,
/// warna dihitung dari hash agar tetap konsisten.
Color warnaMataKuliah(String mataKuliah) {
  for (final mk in semuaMataKuliah) {
    if (mk.nama.toLowerCase() == mataKuliah.toLowerCase()) return mk.warna;
  }
  final palet = [
    const Color(0xFF00897B),
    const Color(0xFF1E88E5),
    const Color(0xFF3949AB),
    const Color(0xFF8E24AA),
    const Color(0xFFD81B60),
    const Color(0xFFFB8C00),
    const Color(0xFF43A047),
    const Color(0xFFF9A825),
    const Color(0xFFE53935),
  ];
  return palet[mataKuliah.hashCode.abs() % palet.length];
}

MataKuliah? cariMataKuliah(String nama) {
  for (final mk in semuaMataKuliah) {
    if (mk.nama.toLowerCase() == nama.toLowerCase()) return mk;
  }
  return null;
}

String sksTeks(String nama) {
  final mk = cariMataKuliah(nama);
  return mk == null ? "" : "${mk.sks} SKS";
}
