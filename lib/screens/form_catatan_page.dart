import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/catatan.dart";
import "../models/mata_kuliah.dart";
import "../viewmodels/catatan_view_model.dart";

const Color _teal = Color(0xFF00897B);
const Color _tealDark = Color(0xFF00695C);

class FormCatatanPage extends StatefulWidget {
  final Catatan? awal;
  const FormCatatanPage({super.key, this.awal});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
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

  Future<void> _simpan() async {
    if ((_mataKuliah ?? "").isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pilih mata kuliah")));
      return;
    }
    if (_judul.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Judul wajib diisi")));
      return;
    }
    if (_isi.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Isi catatan wajib diisi")));
      return;
    }
    setState(() => _menyimpan = true);
    try {
      final vm = context.read<CatatanViewModel>();
      if (widget.awal == null) {
        await vm.tambahCatatan(Catatan(
          mataKuliah: _mataKuliah!,
          judul: _judul.text.trim(),
          isi: _isi.text.trim(),
          tanggal: DateTime.now(),
        ));
      } else {
        await vm.ubahCatatan(Catatan(
          id: widget.awal!.id,
          mataKuliah: _mataKuliah!,
          judul: _judul.text.trim(),
          isi: _isi.text.trim(),
          tanggal: widget.awal!.tanggal,
        ));
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
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
      body: ListView(
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
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: _mataKuliah,
                  hint: const Text("Pilih mata kuliah",
                      style: TextStyle(color: Color(0xFF90A4AE))),
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
            child: TextField(
              controller: _judul,
              decoration: const InputDecoration(labelText: "Judul"),
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
            child: TextField(
              controller: _isi,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Isi catatan"),
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
    );
  }
}
