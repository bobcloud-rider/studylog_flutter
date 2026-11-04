class Catatan {
  final int? id;
  final String mataKuliah;
  final String judul;
  final String isi;
  final DateTime tanggal;

  const Catatan({
    this.id,
    required this.mataKuliah,
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  Map<String, Object?> toMap() => {
        if (id != null) "id": id,
        "mata_kuliah": mataKuliah,
        "judul": judul,
        "isi": isi,
        "tanggal": tanggal.toIso8601String(),
      };

  factory Catatan.fromMap(Map<String, Object?> data) => Catatan(
        id: data["id"] as int?,
        mataKuliah: data["mata_kuliah"] as String,
        judul: data["judul"] as String,
        isi: data["isi"] as String,
        tanggal: DateTime.parse(data["tanggal"] as String),
      );
}
