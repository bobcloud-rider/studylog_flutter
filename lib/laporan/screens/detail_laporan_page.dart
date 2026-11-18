import "dart:io";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/laporan.dart";
import "../utils/konstanta.dart";
import "../utils/widget_umum.dart";
import "../viewmodels/laporan_view_model.dart";

/// Detail laporan + titik kontrol sinkronisasi (Kirim / Retry / Hapus).
class DetailLaporanPage extends StatelessWidget {
  final String localId;
  const DetailLaporanPage({super.key, required this.localId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWarnaLatar,
      appBar: AppBar(
        title: const Text("Detail Laporan"),
        backgroundColor: kWarnaUtama,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LaporanViewModel>(
        builder: (context, vm, _) {
          final laporan = vm.cariLocal(localId);
          if (laporan == null) {
            return const Center(child: Text("Laporan tidak ditemukan."));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _kartuUtama(laporan),
              const SizedBox(height: 14),
              _kartuSinkronisasi(context, vm, laporan),
              const SizedBox(height: 14),
              TombolUtama(
                label: laporan.status == StatusKirim.failed
                    ? "Retry Kirim ke Server"
                    : laporan.status == StatusKirim.success
                        ? "Sudah Terkirim"
                        : "Kirim ke Server",
                ikon: laporan.status == StatusKirim.failed
                    ? Icons.refresh
                    : Icons.cloud_upload_outlined,
                memuat: laporan.status == StatusKirim.sending ||
                    laporan.status == StatusKirim.pending,
                onPressed: laporan.status == StatusKirim.success ||
                        laporan.status == StatusKirim.sending
                    ? null
                    : () => vm.kirimLaporan(laporan.localId),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFC62828)),
                  foregroundColor: const Color(0xFFC62828),
                ),
                onPressed: () => _konfirmasiHapus(context, vm, laporan),
                icon: const Icon(Icons.delete_outline),
                label: const Text("Hapus Laporan"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _kartuUtama(Laporan laporan) {
    final warna = warnaStatus(laporan.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warna.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(laporan.judul,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ChipStatus(
                  label: labelStatus(laporan.status),
                  warna: warna,
                  ikon: ikonStatus(laporan.status)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChipStatus(
                  label: laporan.kategori,
                  warna: const Color(0xFF546E7A)),
              ChipStatus(
                  label: "Prioritas ${laporan.prioritas}",
                  warna: const Color(0xFF6A1B9A)),
              ChipStatus(
                  label: formatWaktu(laporan.dibuatPada),
                  warna: const Color(0xFF455A64),
                  ikon: Icons.schedule),
            ],
          ),
          const Divider(height: 24),
          Text(laporan.deskripsi,
              style: const TextStyle(fontSize: 14, height: 1.5)),
          if (laporan.adaFoto) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(laporan.photoPath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  alignment: Alignment.center,
                  color: const Color(0xFFECEFF1),
                  child: const Text("Foto tidak ditemukan di perangkat"),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  laporan.adaLokasi
                      ? "Lokasi: ${laporan.latitude!.toStringAsFixed(5)}, ${laporan.longitude!.toStringAsFixed(5)}"
                      : "Lokasi tidak tersedia (izin ditolak / tidak diambil)",
                  style: const TextStyle(
                      fontSize: 12.5, color: Color(0xFF546E7A)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kartuSinkronisasi(
      BuildContext context, LaporanViewModel vm, Laporan laporan) {
    final teksStatus = switch (laporan.status) {
      StatusKirim.draft =>
        "DRAFT — tersimpan lokal. Belum pernah dikirim ke server.",
      StatusKirim.pending =>
        "PENDING — sudah masuk antrean, menunggu dikirim.",
      StatusKirim.sending => "SENDING — sedang menghubungi server...",
      StatusKirim.success =>
        "SUCCESS — diterima server (serverId ${laporan.serverId ?? "-"}).",
      StatusKirim.failed =>
        "FAILED — pengiriman gagal, data tetap aman di perangkat.",
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Status Sinkronisasi",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(teksStatus,
              style: const TextStyle(fontSize: 13, height: 1.45)),
          if (laporan.lastError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: Color(0xFFC62828)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(laporan.lastError!,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFC62828))),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text("clientReportId: ${laporan.localId}",
              style: const TextStyle(
                  fontSize: 10.5, color: Color(0xFF90A4AE))),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus(
      BuildContext context, LaporanViewModel vm, Laporan laporan) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus laporan?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("\u201c${laporan.judul}\u201d akan dihapus dari perangkat.",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
                "Kalau laporan ini belum terkirim, datanya tidak bisa dikembalikan."),
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
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (yakin != true) {
      if (yakin == false) {
        tampilkanSnack(context, "Penghapusan dibatalkan, laporan tetap ada.");
      }
      return;
    }
    await vm.hapusLaporan(laporan.localId);
    if (!context.mounted) return;
    tampilkanSnack(context, "Laporan dihapus dari perangkat.");
    Navigator.pop(context);
  }
}
