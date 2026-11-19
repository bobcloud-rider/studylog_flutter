/// US-05 — menyalin ringkasan aduan ke papan klip.
///
/// Semua fungsi di sini MURNI (tanpa widget, tanpa database, tanpa clipboard),
/// supaya bisa diuji tanpa perangkat. Pemanggilan `Clipboard.setData` ada di
/// lapisan UI (detail_laporan_page.dart dan daftar_laporan_page.dart).
library;

import "../models/laporan.dart";
import "konstanta.dart";

/// Teks lokasi yang aman ditampilkan: koordinat atau keterangan tidak tersedia.
String teksLokasi(Laporan laporan) {
  if (!laporan.adaLokasi) return "tidak tersedia";
  final lat = laporan.latitude!.toStringAsFixed(5);
  final lng = laporan.longitude!.toStringAsFixed(5);
  return "$lat, $lng";
}

/// Ringkasan satu aduan dalam bentuk teks biasa (aman untuk WhatsApp/catatan).
///
/// [penanda] dipakai untuk penomoran saat menyalin banyak aduan, mis. "1. ".
String ringkasanSatuLaporan(Laporan laporan, {String penanda = ""}) {
  final b = StringBuffer();
  b.writeln("${penanda}Judul     : ${laporan.judul}");
  b.writeln("Kategori  : ${laporan.kategori}");
  b.writeln("Prioritas : ${laporan.prioritas}");
  b.writeln("Status    : ${labelStatus(laporan.status)}");
  b.writeln("Dibuat    : ${formatWaktu(laporan.dibuatPada)}");
  b.writeln("Lokasi    : ${teksLokasi(laporan)}");
  b.writeln("Foto      : ${laporan.adaFoto ? "ada" : "tidak ada"}");
  b.writeln("ID aduan  : ${laporan.localId}");
  b.write("Deskripsi : ${laporan.deskripsi}");
  return b.toString();
}

/// Ringkasan satu aduan, sudah lengkap dengan judul untuk ditempel.
String ringkasanUntukClipboard(Laporan laporan) {
  return "RINGKASAN ADUAN FASILITAS KAMPUS\n"
      "--------------------------------\n"
      "${ringkasanSatuLaporan(laporan)}";
}

/// Ringkasan beberapa aduan sekaligus, bernomor 1..n.
///
/// [waktuSalin] boleh diisi pada pengujian supaya hasilnya dapat diprediksi;
/// di aplikasi cukup dibiarkan (memakai waktu sekarang).
String ringkasanBanyakLaporan(List<Laporan> daftar, {DateTime? waktuSalin}) {
  if (daftar.isEmpty) {
    return "Belum ada aduan untuk disalin.";
  }
  final waktu = waktuSalin ?? DateTime.now();
  final b = StringBuffer();
  b.writeln("RINGKASAN ADUAN FASILITAS KAMPUS");
  b.writeln("Jumlah  : ${daftar.length} aduan");
  b.writeln("Disalin : ${formatWaktu(waktu)}");
  b.writeln("--------------------------------");
  for (var i = 0; i < daftar.length; i++) {
    b.writeln(ringkasanSatuLaporan(daftar[i], penanda: "${i + 1}. "));
    if (i != daftar.length - 1) {
      b.writeln();
    }
  }
  return b.toString().trimRight();
}
