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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FormCatatanPage(awal: data)),
                ),
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
                onPressed: () => _konfirmasiHapus(context, vm, data.id!),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFE57373)),
                label: const Text("Hapus",
                    style: TextStyle(color: Color(0xFFE57373))),
              ),
            ],
          );
        }),
      );

  Future<void> _konfirmasiHapus(
      BuildContext context, CatatanViewModel vm, int id) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus catatan?"),
        content: const Text("Catatan yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Batal")),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Hapus")),
        ],
      ),
    );
    if (yakin != true || !context.mounted) return;
    try {
      await vm.hapusCatatan(id);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
    }
  }
}
