import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

// Ganti "studylog" sesuai `name:` pada pubspec.yaml proyek Anda.
import "package:studylog_flutter/screens/form_catatan_page.dart";
import "package:studylog_flutter/screens/tentang_page.dart";

Widget bungkus(Widget halaman) => MaterialApp(home: halaman);

void main() {
  group("T7 - validasi form (tanpa Provider, murni widget)", () {
    testWidgets("semua field kosong -> tiga pesan wajib diisi tampil",
        (tester) async {
      await tester.pumpWidget(bungkus(const FormCatatanPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Simpan"));
      await tester.pumpAndSettle();

      expect(find.text("Mata kuliah wajib dipilih"), findsOneWidget);
      expect(find.text("Judul wajib diisi"), findsOneWidget);
      expect(find.text("Isi catatan wajib diisi"), findsOneWidget);
      // SnackBar penanda kondisi error
      expect(find.text("Periksa kembali field yang wajib diisi"),
          findsOneWidget);
    });

    testWidgets("field berisi spasi saja -> validasi menolak",
        (tester) async {
      await tester.pumpWidget(bungkus(const FormCatatanPage()));
      await tester.pumpAndSettle();

      // field ke-0 = Judul, field ke-1 = Isi catatan
      await tester.enterText(find.byType(TextFormField).at(0), "     ");
      await tester.enterText(find.byType(TextFormField).at(1), "Isi yang valid");
      await tester.tap(find.text("Simpan"));
      await tester.pumpAndSettle();

      expect(find.text("Judul wajib diisi"), findsOneWidget);
      expect(find.text("Isi catatan wajib diisi"), findsNothing);
    });
  });

  group("Halaman Tentang Aplikasi", () {
    testWidgets("menampilkan judul aplikasi dan info teknologi",
        (tester) async {
      await tester.pumpWidget(bungkus(const TentangPage()));
      await tester.pumpAndSettle();

      expect(find.text("Tentang Aplikasi"), findsOneWidget);
      expect(find.text("StudyLog"), findsOneWidget);
      expect(find.text("Teknologi"), findsOneWidget);
    });
  });
}
