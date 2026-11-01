import "package:flutter/material.dart";

const Color _teal = Color(0xFF00897B);
const Color _tealDark = Color(0xFF00695C);
const Color _tealLight = Color(0xFFE0F2F1);

void main() => runApp(const StudyLogApp());

class StudyLogApp extends StatelessWidget {
  const StudyLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "StudyLog | Praktikum 1",
      theme: ThemeData(
        colorSchemeSeed: _teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8F8),
      ),
      home: const CatatanFormSederhana(),
    );
  }
}

class CatatanFormSederhana extends StatefulWidget {
  const CatatanFormSederhana({super.key});

  @override
  State<CatatanFormSederhana> createState() => _CatatanFormSederhanaState();
}

class _CatatanFormSederhanaState extends State<CatatanFormSederhana> {
  final _formKey = GlobalKey<FormState>();
  final _mataKuliah = TextEditingController();
  final _judul = TextEditingController();
  final _isi = TextEditingController();
  String? _hasil;

  @override
  void dispose() {
    _mataKuliah.dispose();
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  void _tampilkan() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _hasil = "${_mataKuliah.text.trim()} | ${_judul.text.trim()}";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Data ditampilkan (belum tersimpan permanen)."),
        backgroundColor: _tealDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("StudyLog - Form Catatan"),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _heroHeader(),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _input(
                  _mataKuliah,
                  "Mata kuliah",
                  icon: Icons.book_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Mata kuliah wajib diisi" : null,
                ),
                const SizedBox(height: 14),
                _input(
                  _judul,
                  "Judul catatan",
                  icon: Icons.title_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Judul wajib diisi" : null,
                ),
                const SizedBox(height: 14),
                _input(
                  _isi,
                  "Isi catatan",
                  icon: Icons.article_outlined,
                  baris: 4,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Isi catatan wajib diisi" : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _tampilkan,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text(
              "Tampilkan Catatan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (_hasil != null) ...[
            const SizedBox(height: 24),
            _hasilCard(),
          ],
        ],
      ),
    );
  }

  Widget _heroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: _teal,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_rounded, size: 36, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            "Praktikum 1: State & Interaksi",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            "Formulir interaktif untuk mencatat materi kuliah",
            style: TextStyle(fontSize: 14, color: Color(0xFFB2DFDB)),
          ),
        ],
      ),
    );
  }

  Widget _hasilCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _tealLight),
        boxShadow: [
          BoxShadow(
              color: _teal.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            margin: const EdgeInsets.only(top: 6, bottom: 6, left: 12),
            decoration: const BoxDecoration(
              color: _teal,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hasil input",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: _tealDark),
                ),
                const SizedBox(height: 6),
                Text(_hasil!, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController kontrol,
    String label, {
    required IconData icon,
    int baris = 1,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: kontrol,
      maxLines: baris,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: _tealDark, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: Icon(icon, color: _teal),
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
    );
  }
}
