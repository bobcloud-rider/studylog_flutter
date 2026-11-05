import "package:flutter/material.dart";

import "../models/mata_kuliah.dart";

const Color _teal = Color(0xFF00897B);

/// M2 - Layar ke-5: "Tentang Aplikasi".
/// Dibuka dari BerandaPage lewat Navigator.push (membuktikan Navigator bekerja).
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    final totalSks =
    semuaMataKuliah.fold<int>(0, (jumlah, mk) => jumlah + mk.sks);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: _teal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded,
                        size: 32, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "StudyLog",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Versi 1.0.0 · Praktikum 3: Penyimpanan SQLite",
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFFB2DFDB)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _kartu(
            ikon: Icons.info_outline,
            warna: _teal,
            judul: "Deskripsi",
            isi:
            "StudyLog adalah aplikasi catatan kuliah sederhana yang menyimpan "
                "seluruh data di perangkat (offline). Setiap catatan berisi mata "
                "kuliah, judul, isi, dan tanggal pembuatan.",
          ),
          const SizedBox(height: 12),
          _kartu(
            ikon: Icons.storage,
            warna: const Color(0xFF1E88E5),
            judul: "Teknologi",
            isi:
            "Flutter (Dart) · Material 3 · Provider/ChangeNotifier sebagai "
                "pengelola state · sqflite (SQLite) sebagai penyimpanan lokal.",
          ),
          const SizedBox(height: 12),
          _kartu(
            ikon: Icons.school_outlined,
            warna: const Color(0xFF3949AB),
            judul: "Data Mata Kuliah",
            isi:
            "${semuaMataKuliah.length} mata kuliah · $totalSks SKS "
                "(Semester Ganjil 2026, kelas IFB5A).",
          ),
          const SizedBox(height: 12),
          _kartu(
            ikon: Icons.person_outline,
            warna: const Color(0xFF8E24AA),
            judul: "Pengembang",
            isi: "Mahasiswa IFB5A — Teknologi Aplikasi Bergerak.",
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Kembali ke Beranda",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _kartu({
    required IconData ikon,
    required Color warna,
    required String judul,
    required String isi,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warna.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: warna.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, color: warna, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  isi,
                  style: const TextStyle(
                      fontSize: 13, height: 1.45, color: Color(0xFF607D8B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
