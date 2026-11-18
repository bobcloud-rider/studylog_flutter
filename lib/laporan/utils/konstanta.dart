import "package:flutter/material.dart";

import "../models/laporan.dart";

const Color kWarnaUtama = Color(0xFF00695C);
const Color kWarnaLatar = Color(0xFFF1F6F5);

const List<String> kKategori = <String>[
  "Lampu & Listrik",
  "AC & Ventilasi",
  "Jaringan & Wi-Fi",
  "Laboratorium",
  "Kebersihan",
  "Lainnya",
];

const List<String> kPrioritas = <String>["Rendah", "Sedang", "Tinggi"];

String labelStatus(StatusKirim status) {
  switch (status) {
    case StatusKirim.draft:
      return "DRAFT";
    case StatusKirim.pending:
      return "PENDING";
    case StatusKirim.sending:
      return "SENDING";
    case StatusKirim.success:
      return "SUCCESS";
    case StatusKirim.failed:
      return "FAILED";
  }
}

Color warnaStatus(StatusKirim status) {
  switch (status) {
    case StatusKirim.draft:
      return const Color(0xFF607D8B);
    case StatusKirim.pending:
      return const Color(0xFFFB8C00);
    case StatusKirim.sending:
      return const Color(0xFF1E88E5);
    case StatusKirim.success:
      return const Color(0xFF2E7D32);
    case StatusKirim.failed:
      return const Color(0xFFC62828);
  }
}

IconData ikonStatus(StatusKirim status) {
  switch (status) {
    case StatusKirim.draft:
      return Icons.edit_note;
    case StatusKirim.pending:
      return Icons.hourglass_empty;
    case StatusKirim.sending:
      return Icons.cloud_upload;
    case StatusKirim.success:
      return Icons.cloud_done;
    case StatusKirim.failed:
      return Icons.cloud_off;
  }
}

String formatWaktu(DateTime waktu) {
  String dua(int angka) => angka.toString().padLeft(2, "0");
  return "${dua(waktu.day)}/${dua(waktu.month)}/${waktu.year} "
      "${dua(waktu.hour)}:${dua(waktu.minute)}";
}
