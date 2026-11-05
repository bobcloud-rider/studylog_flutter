import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/catatan.dart";
import "../models/mata_kuliah.dart";
import "../viewmodels/catatan_view_model.dart";
import "form_catatan_page.dart";

const Color _teal = Color(0xFF00897B);

Color _warnaTeks(Color warna) {
  return Color.lerp(warna, const Color(0xFF000000), 0.28)!;
}

class DetailCatatanPage extends StatelessWidget {
  final int id;
  const DetailCatatanPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("Detail Catatan"),
      backgroundColor: _teal,
      foregroundColor: Colors.white,
    ),
    body: Consumer<CatatanViewModel>(builder: (context, vm, _) {
      Catatan? catatan;
      for (final item in vm.catatan) {
        if (item.id == id) {
          catatan = item;
          break;
        }
      }
      if (catatan == null) {
        return const Center(child: Text("Catatan tidak ditemukan."));
      }
      final data = catatan;
      final warna = warnaMataKuliah(data.mataKuliah);
      final sks = sksTeks(data.mataKuliah);
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: warna.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: warna.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: warna.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${data.mataKuliah} · $sks",
                    style: TextStyle(
                        fontSize: 12,
                        color: _warnaTeks(warna),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.judul,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Dibuat: ${data.tanggal.day}/${data.tanggal.month}/${data.tanggal.year}",
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF90A4AE)),
                ),
                const Divider(height: 28),
                Text(
                  data.isi,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _bukaFormUbah(context, data),
            icon: const Icon(Icons.edit),
            label: const Text(
              "Ubah",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFE57373)),
            ),
            onPressed: () => _konfirmasiHapus(context, vm, data),
            icon: const Icon(Icons.delete_outline, color: Color(0xFFE57373)),
            label: const Text("Hapus",
                style: TextStyle(color: Color(0xFFE57373))),
          ),
        ],
      );
    }),
  );

  /// M1-T4: setelah judul diubah & disimpan, SnackBar muncul dan
  /// isi card diperbarui (Consumer mendengarkan ViewModel yang sudah reload).
  Future<void> _bukaFormUbah(BuildContext context, Catatan data) async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormCatatanPage(awal: data)),
    );
    if (!context.mounted || hasil != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("Catatan berhasil diperbarui"),
          backgroundColor: _teal,
        ),
      );
  }

  /// T4 (Delete batal) & T5 (Delete setuju).
  /// - Dialog menyebut judul catatan yang akan dihapus.
  /// - Tombol "Hapus" diberi warna merah (aksi merusak), "Batal" di-autofocus.
  /// - Batal / tap di luar dialog = tidak ada data yang dihapus, dan pengguna
  ///   mendapat konfirmasi "Penghapusan dibatalkan" sehingga beda jelas dengan T5.
  Future<void> _konfirmasiHapus(
      BuildContext context, CatatanViewModel vm, Catatan data) async {
    final yakin = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // tap area luar dialog diperlakukan sebagai Batal
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus catatan?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\u201c${data.judul}\u201d akan dihapus permanen.",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text("Catatan yang dihapus tidak dapat dikembalikan."),
          ],
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Batal"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    // Batal (false) atau tap di luar dialog (null) -> data TIDAK dihapus.
    if (yakin != true) {
      if (yakin == false) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text("Penghapusan dibatalkan, catatan tetap tersimpan"),
              backgroundColor: Color(0xFF607D8B),
            ),
          );
      }
      return;
    }

    try {
      await vm.hapusCatatan(data.id!);
      if (!context.mounted) return;
      // T5: hapus disetujui -> item hilang + konfirmasi SnackBar.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("Catatan berhasil dihapus"),
            backgroundColor: _teal,
          ),
        );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
    }
  }
}
