import "package:flutter/material.dart";
import "../laporan/screens/daftar_laporan_page.dart";
import "daftar_catatan_page.dart";
import "tentang_page.dart";

const Color _teal = Color(0xFF00897B);

/// Anggota Kelompok 1 — urutan sesuai yang ditulis di laporan,
/// sengaja TIDAK diurutkan A-Z / nomor absen. (nama, NIM)
const List<(String, String)> _anggotaKelompok = <(String, String)>[
  ("Jonathan Christian Wong", "2411015"),
  ("Faza Rizal Annafi", "2411100"),
  ("Pandu Eka Paksi", "2411019"),
  ("Muhammad Fahrel Moeloek", "2411035"),
  ("Charly Joezer", "2411014"),
];


class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("StudyLog"),
      backgroundColor: _teal,
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        _heroHeader(),
        const SizedBox(height: 16),
        // Profil mahasiswa pemilik aplikasi (aplikasi profil + StudyLog)
        _kartuProfil(),
        const SizedBox(height: 20),
        _fiturCard(
          "CRUD SQLite",
          "Tambah, tampil, ubah, hapus catatan — tersimpan di database",
          Icons.storage,
          _teal,
        ),
        const SizedBox(height: 12),
        _fiturCard(
          "Tetap setelah restart",
          "Data tidak hilang saat aplikasi ditutup dan dibuka ulang",
          Icons.restart_alt,
          const Color(0xFF1E88E5),
        ),
        const SizedBox(height: 12),
        _fiturCard(
          "Tanpa internet",
          "Semua tampil di perangkat, tidak perlu koneksi jaringan",
          Icons.cloud_off,
          const Color(0xFFFB8C00),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DaftarCatatanPage())),
          icon: const Icon(Icons.arrow_forward),
          label: const Text(
            "Lihat Catatan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        // Modul Campus Report: aduan fasilitas kampus (offline-first)
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const DaftarLaporanPage()),
          ),
          icon: const Icon(Icons.report_gmailerrorred),
          label: const Text(
            "Laporkan Fasilitas Kampus",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Campus Report — aduan kerusakan fasilitas, tetap tersimpan walau Wi-Fi kampus mati.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.5, color: Color(0xFF78909C)),
        ),
        const SizedBox(height: 12),
        // M2 - tugas pengayaan: buka halaman "Tentang Aplikasi"
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TentangPage()),
          ),
          icon: const Icon(Icons.info_outline),
          label: const Text(
            "Tentang Aplikasi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Widget _kartuProfil() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Identitas kelas (nama anggota TIDAK diulang di sini) ---
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF00695C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school_rounded, color: _teal, size: 25),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "IFB5A",
                          style: TextStyle(
                            fontSize: 21,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: Color(0xFF00695C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Kelompok 1",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00695C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Informatika · Universitas Mulia",
                      style: TextStyle(fontSize: 12, color: Color(0xFF607D8B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _teal.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          // --- Daftar anggota kelompok: satu nama per baris ---
          Row(
            children: [
              const Icon(Icons.groups_2_outlined, size: 15, color: _teal),
              const SizedBox(width: 6),
              Text(
                "Anggota Kelompok 1 (${_anggotaKelompok.length} orang)",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00695C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < _anggotaKelompok.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // nomor urut
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // nama lengkap (boleh turun baris kalau panjang)
                  Expanded(
                    child: Text(
                      _anggotaKelompok[i].$1,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: i == 0 ? FontWeight.bold : FontWeight.w500,
                        color: const Color(0xFF263238),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // NIM rata kanan, sejajar antar-baris
                  Text(
                    _anggotaKelompok[i].$2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 13, color: _teal),
              SizedBox(width: 4),
              Text(
                "Semester Ganjil 2026",
                style: TextStyle(fontSize: 11, color: Color(0xFF90A4AE)),
              ),
            ],
          ),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_rounded, size: 36, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "Praktikum 3: Penyimpanan SQLite",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 6),
          Text(
            "Catatan kuliah disimpan di perangkat — tetap dapat dibuka tanpa internet",
            style: TextStyle(fontSize: 14, color: Color(0xFFB2DFDB)),
          ),
        ],
      ),
    );
  }

  Widget _fiturCard(String judul, String deskripsi, IconData ikon, Color warna) {
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
                  deskripsi,
                  style:
                  const TextStyle(fontSize: 13, color: Color(0xFF607D8B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
