import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/catatan.dart";
import "../models/mata_kuliah.dart";
import "../viewmodels/catatan_view_model.dart";
import "detail_catatan_page.dart";
import "form_catatan_page.dart";

const Color _teal = Color(0xFF00897B);
const Color _tealDark = Color(0xFF00695C);

Color _warnaTeks(Color warna) {
  return Color.lerp(warna, const Color(0xFF000000), 0.28)!;
}

/// Kelompokkan catatan per mata kuliah, sesuai urutan semuaMataKuliah.
List<MapEntry<String, List<Catatan>>> kelompokByMK(
    List<Catatan> semua, String? filter) {
  final hasil = <MapEntry<String, List<Catatan>>>[];
  for (final mk in semuaMataKuliah) {
    final list = semua
        .where((c) => c.mataKuliah.toLowerCase() == mk.nama.toLowerCase())
        .toList();
    if (list.isNotEmpty && (filter == null || filter == mk.nama)) {
      hasil.add(MapEntry(mk.nama, list));
    }
  }
  // Catatan dengan nama MK di luar daftar tetap ditampilkan
  final lainnya = semua
      .where((c) => semuaMataKuliah
          .every((mk) => mk.nama.toLowerCase() != c.mataKuliah.toLowerCase()))
      .toList();
  if (filter == null && lainnya.isNotEmpty) {
    hasil.add(MapEntry("Lainnya", lainnya));
  }
  return hasil;
}

class DaftarCatatanPage extends StatefulWidget {
  const DaftarCatatanPage({super.key});

  @override
  State<DaftarCatatanPage> createState() => _DaftarCatatanPageState();
}

class _DaftarCatatanPageState extends State<DaftarCatatanPage> {
  String? _filter; // null = semua

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Daftar Catatan"),
          backgroundColor: _teal,
          foregroundColor: Colors.white,
        ),
        body: Consumer<CatatanViewModel>(builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 56, color: Color(0xFFE57373)),
                    const SizedBox(height: 16),
                    Text(
                      vm.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: vm.muatCatatan,
                      child: const Text("Coba lagi"),
                    ),
                  ],
                ),
              ),
            );
          }
          if (vm.catatan.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.note_add_outlined,
                        size: 56, color: Color(0xFFB2DFDB)),
                    SizedBox(height: 16),
                    Text(
                      "Belum ada catatan. Tekan + untuk menambah catatan.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            children: [
              // Filter chip per mata kuliah — scroll horizontal
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip("Semua", null, _teal),
                    ...semuaMataKuliah.map((mk) {
                      return _chip(mk.nama, mk.nama, mk.warna);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Kelompok per mata kuliah
              ...kelompokByMK(vm.catatan, _filter).map(
                (entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(entry.key, entry.value.length),
                    ...entry.value.map((catatan) {
                      return _catatanCard(
                          catatan,
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailCatatanPage(id: catatan.id!),
                                ),
                              ));
                    }),
                  ],
                ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormCatatanPage()),
          ),
          icon: const Icon(Icons.add),
          label: const Text("Tambah"),
        ),
      );

  Widget _chip(String label, String? nilai, Color warna) {
    final aktif = _filter == nilai;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: aktif ? Colors.white : _warnaTeks(warna)),
        backgroundColor: aktif ? warna : Colors.white,
        selected: aktif,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
        onSelected: (_) => setState(() => _filter = nilai),
      ),
    );
  }

  Widget _sectionHeader(String namaMK, int jumlah) {
    final warna = warnaMataKuliah(namaMK);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: warna,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              namaMK,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            jumlah > 1 ? "$jumlah catatan" : "1 catatan",
            style: TextStyle(
                fontSize: 12,
                color: _warnaTeks(warna),
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _catatanCard(Catatan catatan, VoidCallback onTap) {
    final warna = warnaMataKuliah(catatan.mataKuliah);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: warna.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: warna.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              margin: const EdgeInsets.only(top: 4, bottom: 4, left: 12),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catatan.judul,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: warna.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${catatan.mataKuliah} · ${sksTeks(catatan.mataKuliah)}",
                            style: TextStyle(
                                fontSize: 12,
                                color: _warnaTeks(warna),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${catatan.tanggal.day}/${catatan.tanggal.month}/${catatan.tanggal.year}",
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF90A4AE)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: warna),
          ],
        ),
      ),
    );
  }
}
