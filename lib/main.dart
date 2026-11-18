import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "data/catatan_repository.dart";
import "data/database_helper.dart";
import "laporan/data/laporan_repository.dart";
import "laporan/services/api_service.dart";
import "laporan/viewmodels/laporan_view_model.dart";
import "screens/beranda_page.dart";
import "viewmodels/catatan_view_model.dart";

const Color _teal = Color(0xFF00897B);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Modul 1 — StudyLog (catatan kuliah, Praktikum 3)
  final catatanViewModel = CatatanViewModel(
    CatatanRepository(DatabaseHelper.instance),
  )..muatCatatan();

  // Modul 2 — Campus Report (aduan fasilitas kampus, Studi Kasus 2 Lanjutan)
  final laporanViewModel = LaporanViewModel(
    LaporanRepository(DatabaseHelper.instance),
    ApiService(),
  );
  laporanViewModel.muatLaporan();
  laporanViewModel.pulihkanStatusTertinggal();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CatatanViewModel>.value(value: catatanViewModel),
        ChangeNotifierProvider<LaporanViewModel>.value(value: laporanViewModel),
      ],
      child: const StudyLogApp(),
    ),
  );
}

class StudyLogApp extends StatelessWidget {
  const StudyLogApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "StudyLog",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: _teal,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4F8F8),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: _teal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _teal, width: 2),
        ),
      ),
    ),
    home: const BerandaPage(),
  );
}
