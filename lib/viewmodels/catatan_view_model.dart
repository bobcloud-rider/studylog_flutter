import "package:flutter/foundation.dart";

import "../data/catatan_repository.dart";
import "../models/catatan.dart";

class CatatanViewModel extends ChangeNotifier {
  final CatatanRepository repository;
  CatatanViewModel(this.repository);

  List<Catatan> _catatan = [];
  List<Catatan> get catatan => List.unmodifiable(_catatan);
  bool isLoading = false;
  String? error;

  Future<void> muatCatatan() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _catatan = await repository.semua();
    } catch (e) {
      error = "Tidak dapat membaca catatan: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambahCatatan(Catatan baru) async {
    await repository.tambah(baru);
    await muatCatatan();
  }

  Future<void> ubahCatatan(Catatan catatan) async {
    await repository.ubah(catatan);
    await muatCatatan();
  }

  Future<void> hapusCatatan(int id) async {
    await repository.hapus(id);
    await muatCatatan();
  }
}
