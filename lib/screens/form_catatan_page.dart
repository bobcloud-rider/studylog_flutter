import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/catatan.dart";
import "../models/mata_kuliah.dart";
import "../viewmodels/catatan_view_model.dart";

const Color _teal = Color(0xFF00897B);

class FormCatatanPage extends StatefulWidget {
  final Catatan? awal;
  const FormCatatanPage({super.key, this.awal});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  // Kunci Form: dipakai agar SEMUA pesan validasi tampil sekaligus.
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judul;
  late final TextEditingController _isi;
  String? _mataKuliah;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.awal?.judul ?? "");
    _isi = TextEditingController(text: widget.awal?.isi ?? "");
    _mataKuliah = widget.awal?.mataKuliah;
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  // ---- Validasi: semua memakai trim() agar input berisi spasi ditolak ----
  String? _validasiMataKuliah(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) {
      return "Mata kuliah wajib dipilih";
    }
    return null;
  }

  String? _validasiJudul(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) {
      return "Judul wajib diisi";
    }
    if (nilai.trim().length < 3) {
      return "Judul minimal 3 karakter";
    }
    return null;
  }

  String? _validasiIsi(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) {
      return "Isi catatan wajib diisi";
    }
    return null;
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();

    // Validasi SEMUA field sekaligus (M1-T1 & M1-T2).
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("Periksa kembali field yang wajib diisi"),
            backgroundColor: Color(0xFFE53935),
          ),
        );
      return;
    }

    setState(() => _menyimpan = true);
    try {
      final vm = context.read<CatatanViewModel>();
      if (widget.awal == null) {
        await vm.tambahCatatan(Catatan(
          mataKuliah: _mataKuliah!.trim(),
          judul: _judul.text.trim(),
          isi: _isi.text.trim(),
          tanggal: DateTime.now(),
        ));
      } else {
        await vm.ubahCatatan(Catatan(
          id: widget.awal!.id,
          mataKuliah: _mataKuliah!.trim(),
          judul: _judul.text.trim(),
          isi: _isi.text.trim(),
          tanggal: widget.awal!.tanggal,
        ));
      }
      if (!mounted) return;
      // Kirim true ke halaman pemanggil -> pemanggil yang menampilkan
      // SnackBar sukses (M1-T3 / M1-T4) dan list ikut ter-refresh.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.awal == null ? "Tambah Catatan" : "Ubah Catatan"),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Mata Kuliah",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _mataKuliah,
                    isExpanded: true,
                    hint: const Text(
                      "Pilih mata kuliah",
                      style: TextStyle(color: Color(0xFF90A4AE)),
                    ),
                    decoration: const InputDecoration(
                      labelText: "Mata kuliah",
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: _validasiMataKuliah,
                    items: semuaMataKuliah
                        .map((mk) => DropdownMenuItem(
                      value: mk.nama,
                      child: Text(
                        mk.nama,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => _mataKuliah = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCE5E5)),
              ),
              child: TextFormField(
                controller: _judul,
                textInputAction: TextInputAction.next,
                validator: _validasiJudul,
                decoration: const InputDecoration(
                  labelText: "Judul",
                  hintText: "Contoh: Normalisasi sampai 3NF",
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDCE5E5)),
              ),
              child: TextFormField(
                controller: _isi,
                maxLines: 5,
                validator: _validasiIsi,
                decoration: const InputDecoration(
                  labelText: "Isi catatan",
                  hintText: "Tulis ringkasan materi di sini...",
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(_menyimpan ? "Menyimpan..." : "Simpan",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
