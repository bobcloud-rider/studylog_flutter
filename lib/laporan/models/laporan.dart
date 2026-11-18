/// Model data laporan fasilitas kampus.
///
/// Field mengikuti slide "DATA — Model data laporan" (Studi Kasus 2 Lanjutan):
/// localId, title/category/description, priority/createdAt, photoPath,
/// latitude/longitude, serta status/serverId/lastError untuk sinkronisasi.
library;

/// Siklus status sinkronisasi: DRAFT -> PENDING -> SENDING -> SUCCESS / FAILED.
enum StatusKirim { draft, pending, sending, success, failed }

/// Membaca status dari database/service; nilai tak dikenal dianggap [StatusKirim.draft].
StatusKirim statusDari(Object? teks) {
  final cari = teks?.toString();
  for (final status in StatusKirim.values) {
    if (status.name == cari) return status;
  }
  return StatusKirim.draft;
}

class Laporan {
  final String localId;
  final String judul;
  final String kategori;
  final String deskripsi;
  final String prioritas;
  final DateTime dibuatPada;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final StatusKirim status;
  final int? serverId;
  final String? lastError;

  const Laporan({
    required this.localId,
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    required this.prioritas,
    required this.dibuatPada,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.status = StatusKirim.draft,
    this.serverId,
    this.lastError,
  });

  bool get adaFoto => photoPath != null && photoPath!.isNotEmpty;
  bool get adaLokasi => latitude != null && longitude != null;

  /// Laporan boleh dikirim ulang bila belum pernah sukses.
  bool get bisaDikirim =>
      status == StatusKirim.draft ||
      status == StatusKirim.pending ||
      status == StatusKirim.failed;

  /// Salinan dengan perubahan status/serverId/lastError.
  Laporan salinDengan({
    StatusKirim? status,
    int? serverId,
    String? lastError,
    bool hapusError = false,
  }) {
    return Laporan(
      localId: localId,
      judul: judul,
      kategori: kategori,
      deskripsi: deskripsi,
      prioritas: prioritas,
      dibuatPada: dibuatPada,
      photoPath: photoPath,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      serverId: serverId ?? this.serverId,
      lastError: hapusError ? null : (lastError ?? this.lastError),
    );
  }

  Map<String, Object?> toMap() => {
        "local_id": localId,
        "judul": judul,
        "kategori": kategori,
        "deskripsi": deskripsi,
        "prioritas": prioritas,
        "dibuat_pada": dibuatPada.toIso8601String(),
        "photo_path": photoPath,
        "latitude": latitude,
        "longitude": longitude,
        "status": status.name,
        "server_id": serverId,
        "last_error": lastError,
      };

  factory Laporan.fromMap(Map<String, Object?> data) => Laporan(
        localId: data["local_id"] as String,
        judul: data["judul"] as String,
        kategori: data["kategori"] as String,
        deskripsi: data["deskripsi"] as String,
        prioritas: data["prioritas"] as String,
        dibuatPada: DateTime.parse(data["dibuat_pada"] as String),
        photoPath: data["photo_path"] as String?,
        latitude: (data["latitude"] as num?)?.toDouble(),
        longitude: (data["longitude"] as num?)?.toDouble(),
        status: statusDari(data["status"]),
        serverId: (data["server_id"] as num?)?.toInt(),
        lastError: data["last_error"] as String?,
      );

  /// Payload ke `POST /reports` (kontrak slide P4).
  /// `clientReportId` = localId -> kunci idempotensi saat retry.
  Map<String, Object?> kePayload() => {
        "clientReportId": localId,
        "title": judul,
        "category": kategori,
        "description": deskripsi,
        "priority": prioritas,
        "createdAt": dibuatPada.toIso8601String(),
        "latitude": latitude,
        "longitude": longitude,
      };
}
