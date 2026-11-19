import "package:flutter_test/flutter_test.dart";

// Nama paket proyek: studylog_flutter.
import "package:studylog_flutter/laporan/models/laporan.dart";
import "package:studylog_flutter/laporan/utils/ringkasan_laporan.dart";

/// Pengujian US-05 — menyalin ringkasan aduan ke papan klip.
/// Fungsi murni: tidak butuh database, perangkat, maupun clipboard.
void main() {
  Laporan contoh({
    String judul = "Lampu koridor mati",
    String kategori = "Lampu & Listrik",
    String prioritas = "Tinggi",
    StatusKirim status = StatusKirim.draft,
    double? lat = -7.45678,
    double? lng = 112.71234,
    String? foto = "/data/foto.jpg",
  }) =>
      Laporan(
        localId: "abc-123",
        judul: judul,
        kategori: kategori,
        deskripsi: "Lampu di koridor lantai 2 mati sejak Senin.",
        prioritas: prioritas,
        dibuatPada: DateTime(2026, 11, 19, 9, 59),
        photoPath: foto,
        latitude: lat,
        longitude: lng,
        status: status,
      );

  test("ringkasan memuat seluruh field yang diminta", () {
    final teks = ringkasanSatuLaporan(contoh());
    expect(teks, contains("Judul     : Lampu koridor mati"));
    expect(teks, contains("Kategori  : Lampu & Listrik"));
    expect(teks, contains("Prioritas : Tinggi"));
    expect(teks, contains("Status    : DRAFT"));
    expect(teks, contains("Dibuat    : 19/11/2026 09:59"));
    expect(teks, contains("ID aduan  : abc-123"));
    expect(teks, contains("Deskripsi : Lampu di koridor lantai 2 mati"));
  });

  test("lokasi ditulis dengan 5 angka desimal", () {
    expect(ringkasanSatuLaporan(contoh()), contains("Lokasi    : -7.45678, 112.71234"));
  });

  test("lokasi kosong ditulis 'tidak tersedia', bukan null", () {
    final teks = ringkasanSatuLaporan(contoh(lat: null, lng: null));
    expect(teks, contains("Lokasi    : tidak tersedia"));
    expect(teks, isNot(contains("null")));
  });

  test("foto kosong ditulis 'tidak ada'", () {
    final teks = ringkasanSatuLaporan(contoh(foto: null));
    expect(teks, contains("Foto      : tidak ada"));
    expect(ringkasanSatuLaporan(contoh()), contains("Foto      : ada"));
  });

  test("label status mengikuti status aduan", () {
    expect(ringkasanSatuLaporan(contoh(status: StatusKirim.failed)),
        contains("Status    : FAILED"));
    expect(ringkasanSatuLaporan(contoh(status: StatusKirim.success)),
        contains("Status    : SUCCESS"));
    expect(ringkasanSatuLaporan(contoh(status: StatusKirim.pending)),
        contains("Status    : PENDING"));
  });

  test("ringkasan untuk clipboard diberi judul di atasnya", () {
    final teks = ringkasanUntukClipboard(contoh());
    expect(teks.startsWith("RINGKASAN ADUAN FASILITAS KAMPUS"), isTrue);
    expect(teks, contains("Judul     : Lampu koridor mati"));
  });

  test("banyak aduan diberi nomor 1..n sesuai urutan", () {
    final teks = ringkasanBanyakLaporan(
      [
        contoh(judul: "Aduan A"),
        contoh(judul: "Aduan B"),
        contoh(judul: "Aduan C"),
      ],
      waktuSalin: DateTime(2026, 11, 19, 10, 30),
    );
    expect(teks, contains("Jumlah  : 3 aduan"));
    expect(teks, contains("Disalin : 19/11/2026 10:30"));
    expect(teks.indexOf("1. Judul     : Aduan A"), lessThan(teks.indexOf("2. Judul     : Aduan B")));
    expect(teks.indexOf("2. Judul     : Aduan B"), lessThan(teks.indexOf("3. Judul     : Aduan C")));
  });

  test("daftar kosong memberi pesan, bukan teks kosong", () {
    final teks = ringkasanBanyakLaporan(<Laporan>[]);
    expect(teks, "Belum ada aduan untuk disalin.");
  });

  test("hasil tidak mengandung karakter tak terlihat (aman ditempel)", () {
    final teks = ringkasanBanyakLaporan([contoh()], waktuSalin: DateTime(2026, 1, 1));
    expect(teks.contains("\u0000"), isFalse);
    expect(teks.trimRight(), teks); // tidak ada spasi/kosong di akhir
  });
}
