import "package:flutter_test/flutter_test.dart";

// Catatan: ganti "studylog" dengan nilai `name:` di pubspec.yaml Anda
// (mis. package:study_log/... atau package:praktikum3/...).
import "package:studylog_flutter/models/catatan.dart";

void main() {
  group("Model Catatan", () {
    final tanggal = DateTime(2026, 3, 4, 9, 30);

    test("toMap tidak menyertakan id saat catatan baru", () {
      const judul = "Normalisasi sampai 3NF";
      final catatan = Catatan(
        mataKuliah: "Sistem Manajemen Basis Data",
        judul: judul,
        isi: "Ringkasan materi normalisasi.",
        tanggal: tanggal,
      );
      final map = catatan.toMap();

      expect(map.containsKey("id"), isFalse);
      expect(map["mata_kuliah"], "Sistem Manajemen Basis Data");
      expect(map["judul"], judul);
      expect(map["isi"], "Ringkasan materi normalisasi.");
      expect(map["tanggal"], tanggal.toIso8601String());
    });

    test("toMap menyertakan id saat catatan lama (hasil ubah)", () {
      final catatan = Catatan(
        id: 7,
        mataKuliah: "Kriptografi",
        judul: "Kuis 1",
        isi: "Materi kuis.",
        tanggal: tanggal,
      );
      expect(catatan.toMap()["id"], 7);
    });

    test("fromMap membaca kembali hasil toMap (round trip)", () {
      final asli = Catatan(
        id: 12,
        mataKuliah: "Robotika",
        judul: "Tugas 2",
        isi: "Laporan kinematika.",
        tanggal: tanggal,
      );
      final salinan = Catatan.fromMap(asli.toMap());

      expect(salinan.id, 12);
      expect(salinan.mataKuliah, "Robotika");
      expect(salinan.judul, "Tugas 2");
      expect(salinan.isi, "Laporan kinematika.");
      expect(salinan.tanggal, tanggal);
    });
  });
}
