import "package:flutter/material.dart";
import "daftar_catatan_page.dart";
import "tentang_page.dart";

const Color _teal = Color(0xFF00897B);

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
        const SizedBox(height: 24),
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
