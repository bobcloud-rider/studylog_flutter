import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/laporan.dart";
import "../utils/konstanta.dart";
import "../utils/widget_umum.dart";
import "../viewmodels/laporan_view_model.dart";
import "detail_laporan_page.dart";
import "form_laporan_page.dart";

class DaftarLaporanPage extends StatelessWidget {
  const DaftarLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWarnaLatar,
      appBar: AppBar(
        title: const Text("Campus Report"),
        backgroundColor: kWarnaUtama,
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: _RingkasanTotal()),
          ),
        ],
      ),
      body: Consumer<LaporanViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.laporan.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Color(0xFFC62828)),
                    const SizedBox(height: 12),
                    Text(vm.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: vm.muatLaporan,
                      child: const Text("Coba lagi"),
                    ),
                  ],
                ),
              ),
            );
          }
          if (vm.laporan.isEmpty) {
            return const _KeadaanKosong();
          }
          return RefreshIndicator(
            onRefresh: vm.muatLaporan,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _barisStatistik(vm),
                const SizedBox(height: 12),
                ...vm.laporan.map((laporan) => _kartuLaporan(context, vm, laporan)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final hasil = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const FormLaporanPage()),
          );
          if (hasil == true && context.mounted) {
            tampilkanSnack(context, "Laporan baru tersimpan sebagai DRAFT.");
          }
        },
        backgroundColor: kWarnaUtama,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text("Lapor"),
      ),
    );
  }

  Widget _barisStatistik(LaporanViewModel vm) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChipStatus(
            label: "DRAFT ${vm.totalDraft}",
            warna: warnaStatus(StatusKirim.draft),
            ikon: ikonStatus(StatusKirim.draft)),
        ChipStatus(
            label: "MENUNGGU ${vm.totalMenunggu}",
            warna: warnaStatus(StatusKirim.pending),
            ikon: ikonStatus(StatusKirim.pending)),
        ChipStatus(
            label: "SUCCESS ${vm.totalTerkirim}",
            warna: warnaStatus(StatusKirim.success),
            ikon: ikonStatus(StatusKirim.success)),
        ChipStatus(
            label: "FAILED ${vm.totalGagal}",
            warna: warnaStatus(StatusKirim.failed),
            ikon: ikonStatus(StatusKirim.failed)),
      ],
    );
  }

  Widget _kartuLaporan(
      BuildContext context, LaporanViewModel vm, Laporan laporan) {
    final warna = warnaStatus(laporan.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warna.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailLaporanPage(localId: laporan.localId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      laporan.judul,
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ChipStatus(
                      label: labelStatus(laporan.status),
                      warna: warna,
                      ikon: ikonStatus(laporan.status)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(laporan.kategori,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF546E7A))),
                  Text("• ${laporan.prioritas}",
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF546E7A))),
                  if (laporan.adaFoto) const Icon(Icons.image, size: 14),
                  if (laporan.adaLokasi)
                    const Icon(Icons.place, size: 14, color: Color(0xFF1E88E5)),
                ],
              ),
              const SizedBox(height: 4),
              Text(formatWaktu(laporan.dibuatPada),
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF90A4AE))),
              if (laporan.status == StatusKirim.failed &&
                  laporan.lastError != null) ...[
                const SizedBox(height: 6),
                Text(laporan.lastError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 11.5, color: Color(0xFFC62828))),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => vm.kirimLaporan(laporan.localId),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Retry"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RingkasanTotal extends StatelessWidget {
  const _RingkasanTotal();

  @override
  Widget build(BuildContext context) {
    return Consumer<LaporanViewModel>(
      builder: (context, vm, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text("${vm.total} laporan",
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _KeadaanKosong extends StatelessWidget {
  const _KeadaanKosong();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.report_gmailerrorred,
                size: 56, color: Colors.teal.shade200),
            const SizedBox(height: 16),
            const Text(
              "Belum ada laporan.\nTekan tombol Lapor untuk mencatat kerusakan fasilitas.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            const Text(
              "Laporan disimpan dulu di perangkat, jadi tetap bisa dibuat saat Wi-Fi kampus mati.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
            ),
          ],
        ),
      ),
    );
  }
}
