import "package:flutter_test/flutter_test.dart";

// Ganti "studylog" sesuai `name:` pada pubspec.yaml proyek Anda.
import "package:studylog_flutter/models/mata_kuliah.dart";

void main() {
  group("Mata kuliah", () {
    test("daftar mata kuliah terisi dan nama unik", () {
      expect(semuaMataKuliah.length, greaterThanOrEqualTo(4));
      final nama = semuaMataKuliah.map((mk) => mk.nama.toLowerCase()).toList();
      expect(nama.toSet().length, nama.length, reason: "nama MK harus unik");
    });

    test("sksTeks mengembalikan SKS sesuai daftar", () {
      expect(sksTeks("Kriptografi"), "3 SKS");
      expect(sksTeks("Penulisan dan Publikasi Ilmiah"), "2 SKS");
      expect(sksTeks("Mata Kuliah Tidak Dikenal"), "");
    });

    test("cariMataKuliah tidak peka huruf besar/kecil", () {
      expect(cariMataKuliah("kriptografi")?.nama, "Kriptografi");
      expect(cariMataKuliah("KRIPTOGRAFI")?.nama, "Kriptografi");
      expect(cariMataKuliah("Tidak Ada"), isNull);
    });

    test("warnaMataKuliah konsisten untuk nama yang sama", () {
      expect(warnaMataKuliah("Robotika"), warnaMataKuliah("robotika"));
      expect(warnaMataKuliah("Kriptografi"),
          warnaMataKuliah("Kriptografi"));
    });
  });
}
