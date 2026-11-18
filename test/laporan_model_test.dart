import "package:flutter_test/flutter_test.dart";

import "package:studylog_flutter/laporan/models/laporan.dart";

void main() {
  group("Model Laporan (Campus Report)", () {
    final waktu = DateTime(2026, 11, 18, 9, 30);

    Laporan contoh({StatusKirim status = StatusKirim.draft}) => Laporan(
      localId: "3f2b8a1e-0000-4000-8000-000000000001",
      judul: "Lampu laboratorium padam",
      kategori: "Lampu & Listrik",
      deskripsi: "Lampu ruang Lab Komputer 2 padam sejak pagi.",
      prioritas: "Tinggi",
      dibuatPada: waktu,
      photoPath: "/data/user/0/app/files/laporan_1.jpg",
      latitude: -7.446,
      longitude: 112.704,
      status: status,
    );

    test("round-trip toMap -> fromMap tidak mengubah data", () {
      final asli = contoh(status: StatusKirim.failed).salinDengan(
        lastError: "Tidak dapat menghubungi server",
      );
      final salinan = Laporan.fromMap(asli.toMap());

      expect(salinan.localId, asli.localId);
      expect(salinan.judul, asli.judul);
      expect(salinan.kategori, asli.kategori);
      expect(salinan.prioritas, asli.prioritas);
      expect(salinan.dibuatPada, waktu);
      expect(salinan.photoPath, asli.photoPath);
      expect(salinan.latitude, asli.latitude);
      expect(salinan.status, StatusKirim.failed);
      expect(salinan.lastError, "Tidak dapat menghubungi server");
    });

    test("lokasi boleh null (izin ditolak) dan laporan tetap valid", () {
      final tanpaLokasi = Laporan(
        localId: "abc",
        judul: "AC bocor",
        kategori: "AC & Ventilasi",
        deskripsi: "Air menetes di lantai ruang 3.01.",
        prioritas: "Sedang",
        dibuatPada: waktu,
      );
      expect(tanpaLokasi.adaLokasi, isFalse);
      final salinan = Laporan.fromMap(tanpaLokasi.toMap());
      expect(salinan.latitude, isNull);
      expect(salinan.longitude, isNull);
      expect(salinan.status, StatusKirim.draft);
    });

    test("statusDari memberi nilai aman untuk teks tak dikenal", () {
      expect(statusDari("success"), StatusKirim.success);
      expect(statusDari("SENDING"), StatusKirim.draft); // huruf besar = tak dikenal
      expect(statusDari(null), StatusKirim.draft);
      expect(statusDari("ngawur"), StatusKirim.draft);
    });

    test("payload API memakai clientReportId = localId (idempoten)", () {
      final payload = contoh().kePayload();
      expect(payload["clientReportId"], contoh().localId);
      expect(payload["title"], "Lampu laboratorium padam");
      expect(payload["category"], "Lampu & Listrik");
      expect(payload["priority"], "Tinggi");
      expect(payload["createdAt"], waktu.toIso8601String());
      expect(payload["latitude"], -7.446);
    });

    test("bisaDikirim hanya untuk draft/pending/failed", () {
      expect(contoh(status: StatusKirim.draft).bisaDikirim, isTrue);
      expect(contoh(status: StatusKirim.pending).bisaDikirim, isTrue);
      expect(contoh(status: StatusKirim.failed).bisaDikirim, isTrue);
      expect(contoh(status: StatusKirim.sending).bisaDikirim, isFalse);
      expect(contoh(status: StatusKirim.success).bisaDikirim, isFalse);
    });
  });
}
