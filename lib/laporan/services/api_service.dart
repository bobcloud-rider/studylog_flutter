import "dart:async";
import "dart:convert";

import "package:http/http.dart" as http;

import "../models/laporan.dart";

/// Hasil satu percobaan kirim ke server.
class HasilKirim {
  final bool sukses;
  final int? serverId;
  final String? pesan;

  /// true bila server menjawab 200 (clientReportId sudah pernah diterima)
  /// sehingga retry tidak membuat duplikat.
  final bool terduplikasi;

  const HasilKirim({
    required this.sukses,
    this.serverId,
    this.pesan,
    this.terduplikasi = false,
  });

  factory HasilKirim.gagal(String pesan) =>
      HasilKirim(sukses: false, pesan: pesan);
}

/// REST client untuk `POST /reports`.
///
/// Base URL default `http://10.0.2.2:8000` = localhost komputer dilihat dari
/// emulator Android. Untuk HP fisik, jalankan aplikasi dengan:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
class ApiService {
  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ??
            const String.fromEnvironment("API_BASE_URL",
                defaultValue: "http://10.0.2.2:8000"),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const Duration batasWaktu = Duration(seconds: 15);

  Future<HasilKirim> kirimLaporan(Laporan laporan) async {
    final Uri url = Uri.parse("$baseUrl/reports");
    try {
      final respon = await _client
          .post(
            url,
            headers: const {"Content-Type": "application/json"},
            body: jsonEncode(laporan.kePayload()),
          )
          .timeout(batasWaktu);

      // 201 = laporan baru diterima, 200 = clientReportId sudah ada (idempoten)
      if (respon.statusCode == 201 || respon.statusCode == 200) {
        Map<String, dynamic> data = <String, dynamic>{};
        if (respon.body.isNotEmpty) {
          try {
            data = jsonDecode(respon.body) as Map<String, dynamic>;
          } catch (_) {
            data = <String, dynamic>{};
          }
        }
        return HasilKirim(
          sukses: true,
          serverId: (data["serverId"] as num?)?.toInt(),
          terduplikasi: respon.statusCode == 200,
          pesan: respon.statusCode == 200
              ? "Server mengenali laporan yang sama (tidak ada duplikasi)."
              : "Laporan diterima server.",
        );
      }

      if (respon.statusCode >= 400 && respon.statusCode < 500) {
        return HasilKirim.gagal(
            "Ditolak server (${respon.statusCode}): data belum valid.");
      }
      return HasilKirim.gagal("Server bermasalah (${respon.statusCode}).");
    } on TimeoutException {
      return HasilKirim.gagal("Koneksi habis waktu. Periksa jaringan/server.");
    } catch (e) {
      // API mati / tidak ada jaringan: data TETAP tersimpan sebagai FAILED.
      return HasilKirim.gagal("Tidak dapat menghubungi server: $e");
    }
  }

  Future<bool> cekServer() async {
    try {
      final respon =
          await _client.get(Uri.parse("$baseUrl/health")).timeout(batasWaktu);
      return respon.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void tutup() => _client.close();
}
