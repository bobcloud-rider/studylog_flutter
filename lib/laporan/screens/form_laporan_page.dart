import "dart:io";

import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "package:uuid/uuid.dart";

import "../models/laporan.dart";
import "../utils/konstanta.dart";
import "../utils/widget_umum.dart";
import "../viewmodels/laporan_view_model.dart";

/// Form laporan baru. Semua data disimpan LOKAL dulu (status DRAFT);
/// kamera dan lokasi bersifat "best effort" dan tidak menghalangi simpan.
class FormLaporanPage extends StatefulWidget {
  const FormLaporanPage({super.key});

  @override
  State<FormLaporanPage> createState() => _FormLaporanPageState();
}

class _FormLaporanPageState extends State<FormLaporanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();

  String? _kategori;
  String _prioritas = kPrioritas[1];
  String? _photoPath;
  double? _latitude;
  double? _longitude;
  String _infoLokasi = "Lokasi belum diambil (opsional).";
  bool _mengambilLokasi = false;
  bool _menyimpan = false;

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  /// P3: foto diambil lewat kamera, lalu DISALIN ke direktori dokumen aplikasi
  /// supaya path tetap valid setelah cache dibersihkan / aplikasi dibuka ulang.
  Future<void> _ambilFoto() async {
    try {
      final picker = ImagePicker();
      final XFile? foto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (foto == null) return;
      final folder = await getApplicationDocumentsDirectory();
      final namaFile = "laporan_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final tujuan = File("${folder.path}/$namaFile");
      await File(foto.path).copy(tujuan.path);
      if (!mounted) return;
      setState(() => _photoPath = tujuan.path);
      tampilkanSnack(context, "Foto tersimpan di perangkat.");
    } catch (e) {
      if (!mounted) return;
      tampilkanSnack(context, "Kamera tidak tersedia: $e", galat: true);
    }
  }

  /// P3: lokasi opsional. Bila izin ditolak / GPS mati -> koordinat null,
  /// dan laporan TETAP dapat disimpan.
  Future<void> _ambilLokasi() async {
    setState(() => _mengambilLokasi = true);
    try {
      final layananAktif = await Geolocator.isLocationServiceEnabled();
      if (!layananAktif) {
        if (!mounted) return;
        setState(() {
          _infoLokasi = "GPS mati. Laporan tetap bisa disimpan tanpa lokasi.";
          _latitude = null;
          _longitude = null;
        });
        return;
      }
      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.denied ||
          izin == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _infoLokasi =
              "Izin lokasi ditolak. Laporan tetap disimpan tanpa koordinat.";
          _latitude = null;
          _longitude = null;
        });
        return;
      }
      final posisi = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _latitude = posisi.latitude;
        _longitude = posisi.longitude;
        _infoLokasi =
            "Lokasi: ${posisi.latitude.toStringAsFixed(5)}, ${posisi.longitude.toStringAsFixed(5)}";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _infoLokasi = "Gagal mengambil lokasi ($e). Laporan tetap bisa disimpan.";
        _latitude = null;
        _longitude = null;
      });
    } finally {
      if (mounted) setState(() => _mengambilLokasi = false);
    }
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      tampilkanSnack(context, "Periksa kembali field yang wajib diisi.",
          galat: true);
      return;
    }
    setState(() => _menyimpan = true);
    try {
      final laporan = Laporan(
        localId: const Uuid().v4(),
        judul: _judul.text.trim(),
        kategori: _kategori!.trim(),
        deskripsi: _deskripsi.text.trim(),
        prioritas: _prioritas,
        dibuatPada: DateTime.now(),
        photoPath: _photoPath,
        latitude: _latitude,
        longitude: _longitude,
        status: StatusKirim.draft,
      );
      await context.read<LaporanViewModel>().tambahLaporan(laporan);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      tampilkanSnack(context, "Gagal menyimpan: $e", galat: true);
    }
  }

  String? _wajibIsi(String? nilai, String label) {
    if (nilai == null || nilai.trim().isEmpty) return "$label wajib diisi";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWarnaLatar,
      appBar: AppBar(
        title: const Text("Laporan Baru"),
        backgroundColor: kWarnaUtama,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _kotak(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Data Kerusakan",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _judul,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _wajibIsi(v, "Judul laporan"),
                    decoration: const InputDecoration(
                      labelText: "Judul laporan",
                      hintText: "Contoh: Lampu laboratorium komputer padam",
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _kategori,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Kategori",
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Kategori wajib dipilih" : null,
                    items: kKategori
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => setState(() => _kategori = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _prioritas,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Prioritas",
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: kPrioritas
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _prioritas = v ?? _prioritas),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _deskripsi,
                    maxLines: 4,
                    validator: (v) {
                      final dasar = _wajibIsi(v, "Deskripsi");
                      if (dasar != null) return dasar;
                      if (v!.trim().length < 10) {
                        return "Deskripsi minimal 10 karakter";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Deskripsi",
                      alignLabelWithHint: true,
                      hintText: "Jelaskan kondisi kerusakan secara singkat...",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _kotak(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Foto & Lokasi (opsional)",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (_photoPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_photoPath!),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          alignment: Alignment.center,
                          color: const Color(0xFFECEFF1),
                          child: const Text("Foto tidak dapat ditampilkan"),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _ambilFoto,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: Text(_photoPath == null
                              ? "Ambil Foto"
                              : "Ganti Foto"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              _mengambilLokasi ? null : _ambilLokasi,
                          icon: _mengambilLokasi
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, size: 18),
                          label: const Text("Ambil Lokasi"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_infoLokasi,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF607D8B))),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TombolUtama(
              label: _menyimpan ? "Menyimpan..." : "Simpan Draft (Offline)",
              ikon: Icons.save_outlined,
              memuat: _menyimpan,
              onPressed: _simpan,
            ),
            const SizedBox(height: 8),
            const Text(
              "Data disimpan ke SQLite lebih dulu. Pengiriman ke server dilakukan dari halaman detail.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Color(0xFF78909C)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kotak({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE5E5)),
        ),
        child: child,
      );
}
