import "package:flutter/material.dart";

const Color _teal = Color(0xFF00695C);

class ChipStatus extends StatelessWidget {
  final String label;
  final Color warna;
  final IconData? ikon;
  const ChipStatus({
    super.key,
    required this.label,
    required this.warna,
    this.ikon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warna.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 13, color: warna),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: warna),
          ),
        ],
      ),
    );
  }
}

class KartuInfo extends StatelessWidget {
  final IconData ikon;
  final Color warna;
  final String judul;
  final String isi;
  const KartuInfo({
    super.key,
    required this.ikon,
    required this.warna,
    required this.judul,
    required this.isi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warna.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: warna.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, color: warna, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(isi,
                    style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Color(0xFF546E7A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TombolUtama extends StatelessWidget {
  final String label;
  final IconData ikon;
  final VoidCallback? onPressed;
  final bool memuat;
  const TombolUtama({
    super.key,
    required this.label,
    required this.ikon,
    this.onPressed,
    this.memuat = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: memuat ? null : onPressed,
      icon: memuat
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(ikon),
      label: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}

/// SnackBar seragam untuk seluruh layar.
void tampilkanSnack(BuildContext context, String pesan, {bool galat = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(pesan),
      backgroundColor: galat ? const Color(0xFFC62828) : _teal,
    ));
}
