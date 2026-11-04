import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "data/catatan_repository.dart";
import "data/database_helper.dart";
import "screens/beranda_page.dart";
import "viewmodels/catatan_view_model.dart";

const Color _teal = Color(0xFF00897B);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          CatatanViewModel(CatatanRepository(DatabaseHelper.instance))
              ..muatCatatan(),
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
