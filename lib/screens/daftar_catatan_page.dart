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

/// US-05 — pilihan urutan daftar catatan.
const List<String> pilihanUrutan = [
  "Terbaru",
  "Terlama",
  "Judul A–Z",
  "Judul Z–A",
];

/// Mengurutkan catatan sesuai mode yang dipilih.
///
/// - "Terbaru"  : tanggal terbesar dulu (default)
/// - "Terlama"  : tanggal terkecil dulu
/// - "Judul A–Z": abjad menaik, tidak peka huruf besar/kecil
/// - "Judul Z–A": abjad menurun
///
/// Bila tanggalnya sama, urutan dirapikan dengan judul supaya hasilnya
/// selalu konsisten (tidak berubah-ubah antar pemanggilan).
List<Catatan> urutkanCatatan(List<Catatan> data, String mode) {
  final hasil = List<Catatan>.from(data);

  int abjad(Catatan a, Catatan b) =>
      a.judul.toLowerCase().compareTo(b.judul.toLowerCase());

  switch (mode) {
    case "Terlama":
      hasil.sort((a, b) {
        final t = a.tanggal.compareTo(b.tanggal);
        return t != 0 ? t : abjad(a, b);
      });
      break;
    case "Judul A–Z":
      hasil.sort(abjad);
      break;
    case "Judul Z–A":
      hasil.sort((a, b) => abjad(b, a));
      break;
    case "Terbaru":
    default:
      hasil.sort((a, b) {
        final t = b.tanggal.compareTo(a.tanggal);
        return t != 0 ? t : abjad(a, b);
      });
  }
  return hasil;
}

/// US-03 — pencarian berdasarkan JUDUL.
///
/// Aturan:
/// - tidak peka huruf besar/kecil (semua dibandingkan dalam lowercase)
/// - spasi di awal/akhir diabaikan
/// - kata kunci kosong = semua catatan dikembalikan
/// - hanya mencocokkan `judul`, bukan `isi` (sesuai user story)
List<Catatan> cariCatatanByJudul(List<Catatan> semua, String kataKunci) {
  final kunci = kataKunci.trim().toLowerCase();
  if (kunci.isEmpty) return List<Catatan>.from(semua);
  return semua
      .where((c) => c.judul.toLowerCase().contains(kunci))
      .toList();
}

/// M2 - tugas pengayaan: jumlah TOTAL catatan, dihitung lewat Consumer
/// sehingga otomatis berubah setiap kali ViewModel notifyListeners()
/// (tambah / ubah / hapus). Tetap tampil walau daftar masih kosong.
class _TotalCatatan extends StatelessWidget {
  const _TotalCatatan();

  @override
  Widget build(BuildContext context) {
    return Consumer<CatatanViewModel>(
      builder: (context, vm, _) {
        final jumlah = vm.catatan.length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notes, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                jumlah == 0 ? "Belum ada catatan" : "Total $jumlah catatan",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DaftarCatatanPage extends StatefulWidget {
  const DaftarCatatanPage({super.key});

  @override
  State<DaftarCatatanPage> createState() => _DaftarCatatanPageState();
}

class _DaftarCatatanPageState extends State<DaftarCatatanPage> {
  String? _filter; // null = semua

  // US-03: kata kunci pencarian judul
  final TextEditingController _cari = TextEditingController();
  String _kataKunci = "";

  // US-05: mode urutan daftar
  String _urutan = pilihanUrutan.first; // "Terbaru"

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Daftar Catatan"),
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(child: _TotalCatatan()),
            ),
          ],
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
          final hasilCari = cariCatatanByJudul(vm.catatan, _kataKunci);
          final kelompok = kelompokByMK(hasilCari, _filter)
              .map((e) => MapEntry(e.key, urutkanCatatan(e.value, _urutan)))
              .toList();

          return Column(
            children: [
              _kolomCari(),
              _barisUrutan(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
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
                    // Kelompok per mata kuliah (sudah terfilter pencarian)
                    if (kelompok.isEmpty)
                      _pesanKosong()
                    else
                      ...kelompok.map(
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
                ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _bukaFormTambah,
          icon: const Icon(Icons.add),
          label: const Text("Tambah"),
        ),
      );

  /// M1-T3: setelah form tersimpan, tampilkan SnackBar sukses.
  /// Card baru otomatis muncul karena ViewModel memanggil muatCatatan()
  /// lalu notifyListeners() -> Consumer di halaman ini rebuild.
  Future<void> _bukaFormTambah() async {
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FormCatatanPage()),
    );
    if (!mounted || hasil != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("Catatan berhasil disimpan"),
          backgroundColor: _tealDark,
        ),
      );
  }

  /// US-05: tombol pemilih urutan, membuka bottom sheet berisi 4 pilihan.
  Widget _barisUrutan() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _pilihUrutan,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _teal.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, size: 16, color: _tealDark),
                const SizedBox(width: 6),
                Text(
                  "Urutan: $_urutan",
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _tealDark),
                ),
                const Icon(Icons.expand_more, size: 16, color: _tealDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pilihUrutan() async {
    final dipilih = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Urutkan catatan",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ...pilihanUrutan.map(
              (p) => ListTile(
                leading: Icon(
                  p == _urutan
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: _tealDark,
                ),
                title: Text(
                  p,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        p == _urutan ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, p),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || dipilih == null) return;
    setState(() => _urutan = dipilih);
  }

  /// US-03: kolom pencarian judul. Selalu terlihat (tidak ikut ter-scroll),
  /// supaya pengguna bisa menghapus kata kunci tanpa menggulir ke atas.
  Widget _kolomCari() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _cari,
        textInputAction: TextInputAction.search,
        onChanged: (v) => setState(() => _kataKunci = v),
        decoration: InputDecoration(
          hintText: "Cari judul catatan…",
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF90A4AE)),
          prefixIcon: const Icon(Icons.search, size: 20, color: _teal),
          suffixIcon: _kataKunci.isEmpty
              ? null
              : IconButton(
                  tooltip: "Hapus pencarian",
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _cari.clear();
                    setState(() => _kataKunci = "");
                  },
                ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _teal.withValues(alpha: 0.35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _teal, width: 1.6),
          ),
        ),
      ),
    );
  }

  /// Ditampilkan bila kombinasi pencarian + filter tidak menghasilkan apa pun.
  Widget _pesanKosong() {
    final adaKunci = _kataKunci.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(adaKunci ? Icons.search_off_rounded : Icons.filter_alt_off_rounded,
              size: 56, color: const Color(0xFFB2DFDB)),
          const SizedBox(height: 16),
          Text(
            adaKunci
                ? "Tidak ada catatan dengan judul mengandung \"${_kataKunci.trim()}\"."
                : "Tidak ada catatan pada kategori ini.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF546E7A)),
          ),
          if (adaKunci) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                _cari.clear();
                setState(() => _kataKunci = "");
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Hapus pencarian"),
            ),
          ],
        ],
      ),
    );
  }

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
