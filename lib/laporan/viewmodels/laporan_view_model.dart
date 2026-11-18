import "package:flutter/foundation.dart";

import "../data/laporan_repository.dart";
import "../models/laporan.dart";
import "../services/api_service.dart";

/// ViewModel: satu-satunya tempat aturan main status sinkronisasi.
/// View hanya membaca state dan memanggil command di sini.
class LaporanViewModel extends ChangeNotifier {
  final LaporanRepository repository;
  final ApiService api;

  LaporanViewModel(this.repository, this.api);

  List<Laporan> _laporan = <Laporan>[];
  List<Laporan> get laporan => List.unmodifiable(_laporan);

  bool isLoading = false;
  String? error;
  String? pesan; // pesan sekali-tampil untuk SnackBar

  int get total => _laporan.length;
  int get totalDraft =>
      _laporan.where((l) => l.status == StatusKirim.draft).length;
  int get totalTerkirim =>
      _laporan.where((l) => l.status == StatusKirim.success).length;
  int get totalGagal =>
      _laporan.where((l) => l.status == StatusKirim.failed).length;
  int get totalMenunggu => _laporan
      .where((l) =>
          l.status == StatusKirim.pending || l.status == StatusKirim.sending)
      .length;

  Laporan? cariLocal(String localId) {
    for (final laporan in _laporan) {
      if (laporan.localId == localId) return laporan;
    }
    return null;
  }

  void ambilPesan() {
    pesan = null;
  }

  Future<void> muatLaporan() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _laporan = await repository.semua();
    } catch (e) {
      error = "Gagal membaca database: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Dipanggil sekali saat startup: laporan yang tertinggal di status SENDING
  /// (aplikasi ditutup di tengah pengiriman) dijadikan FAILED agar bisa di-retry.
  Future<void> pulihkanStatusTertinggal() async {
    await repository.tandaiSendingMenjadiGagal();
    await muatLaporan();
  }

  Future<void> tambahLaporan(Laporan laporan) async {
    await repository.tambah(laporan);
    pesan = "Laporan tersimpan sebagai ${laporan.status.name.toUpperCase()} (lokal).";
    await muatLaporan();
  }

  Future<void> ubahLaporan(Laporan laporan) async {
    await repository.ubah(laporan);
    pesan = "Perubahan laporan tersimpan.";
    await muatLaporan();
  }

  Future<void> hapusLaporan(String localId) async {
    await repository.hapus(localId);
    pesan = "Laporan dihapus dari perangkat.";
    await muatLaporan();
  }

  /// Alur kirim: PENDING -> SENDING -> SUCCESS / FAILED.
  /// Menggunakan localId yang sama setiap kali retry (idempoten).
  Future<void> kirimLaporan(String localId) async {
    final laporan = cariLocal(localId);
    if (laporan == null) return;
    if (laporan.status == StatusKirim.success ||
        laporan.status == StatusKirim.sending) {
      return;
    }

    // 1. Antrekan
    await repository
        .ubah(laporan.salinDengan(status: StatusKirim.pending, hapusError: true));
    await muatLaporan();

    // 2. Sedang dikirim (kalau app mati di titik ini -> pulihkanStatusTertinggal)
    final antre = cariLocal(localId) ?? laporan;
    await repository.ubah(
        antre.salinDengan(status: StatusKirim.sending, hapusError: true));
    await muatLaporan();

    // 3. Tembak API
    final hasil = await api.kirimLaporan(antre);

    // 4. Simpan hasil: data tidak pernah dihapus walau gagal
    if (hasil.sukses) {
      await repository.ubah(antre.salinDengan(
        status: StatusKirim.success,
        serverId: hasil.serverId,
        hapusError: true,
      ));
      pesan = hasil.terduplikasi
          ? "Server sudah punya laporan ini (serverId ${hasil.serverId}). Tidak ada duplikasi."
          : "Laporan terkirim (serverId ${hasil.serverId}).";
    } else {
      await repository.ubah(antre.salinDengan(
        status: StatusKirim.failed,
        lastError: hasil.pesan,
      ));
      pesan = "Gagal kirim: ${hasil.pesan}. Data tetap tersimpan, silakan Retry.";
    }
    await muatLaporan();
  }
}
