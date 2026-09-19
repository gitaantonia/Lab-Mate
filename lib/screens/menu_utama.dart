import 'package:flutter/material.dart';
import 'mata_praktikan_screen.dart';
import 'praktikan/praktikan_screen.dart';
import 'nilai/input_nilai_screen.dart';
import 'nilai/kelompok_screen.dart';
import 'nilai/lihat_nilai_screen.dart';
import 'nilai/rekap_nilai_screen.dart';
import 'kalkulator_umur_screen.dart';
import 'konversi_kalender_screen.dart';
import 'detail_kelas_praktikan_screen.dart';

class MenuUtama {
  final String judul;
  final String deskripsi;
  final IconData ikon;
  final Color warna;
  final WidgetBuilder builder;

  const MenuUtama({
    required this.judul,
    required this.deskripsi,
    required this.ikon,
    this.warna = const Color(0xFF2563EB),
    required this.builder,
  });
}

List<MenuUtama> getSemuaMenu(String role) {
  if (role == 'aslab') {
    return [
      MenuUtama(
        judul: 'Daftar Anggota',
        deskripsi: 'Tambah, edit, dan kelola data praktikan',
        ikon: Icons.people_alt_rounded,
        warna: const Color(0xFF2563EB), // Blue
        builder: (_) => const PraktikanScreen(),
      ),
      MenuUtama(
        judul: 'Kelola Data Praktikum',
        deskripsi: 'Kelola mata praktikum & komponen bobot',
        ikon: Icons.auto_stories_rounded,
        warna: const Color(0xFF0D9488), // Teal
        builder: (_) => const MataPraktikumScreen(),
      ),
      MenuUtama(
        judul: 'Komputasi Nilai',
        deskripsi: 'Input nilai praktikan & hitung nilai akhir',
        ikon: Icons.calculate_rounded,
        warna: const Color(0xFF7C3AED), // Violet
        builder: (_) => const NilaiInputScreen(),
      ),
      MenuUtama(
        judul: 'Kelompok Praktikum',
        deskripsi: 'Lihat & bagi kelompok praktikum otomatis',
        ikon: Icons.groups_rounded,
        warna: const Color(0xFF0284C7), // Sky Blue
        builder: (_) => const KelompokScreen(),
      ),
      MenuUtama(
        judul: 'Rekap Nilai Praktikan',
        deskripsi: 'Rekapitulasi nilai & grade seluruh praktikan',
        ikon: Icons.table_chart_rounded,
        warna: const Color(0xFFEA580C), // Orange
        builder: (_) => const RekapNilaiScreen(),
      ),
      MenuUtama(
        judul: 'Kalkulator Umur',
        deskripsi: 'Hitung presisi usia dari tanggal acuan',
        ikon: Icons.cake_rounded,
        warna: const Color(0xFFDB2777), // Pink
        builder: (_) => const KalkulatorUmurScreen(),
      ),
      MenuUtama(
        judul: 'Konversi Kalender',
        deskripsi: 'Penanggalan Hijriah, Weton Jawa, & Saka Bali',
        ikon: Icons.event_note_rounded,
        warna: const Color(0xFF059669), // Emerald
        builder: (_) => const KonversiKalenderScreen(),
      ),
    ];
  }

  return [
    MenuUtama(
      judul: 'Lihat Nilai Saya',
      deskripsi: 'Cek rincian skor komponen & Nilai Akhir + Grade',
      ikon: Icons.analytics_rounded,
      warna: const Color(0xFF2563EB),
      builder: (_) => const LihatNilaiScreen(),
    ),
    MenuUtama(
      judul: 'Kalkulator Umur',
      deskripsi: 'Hitung presisi usia dari tanggal acuan mana saja',
      ikon: Icons.cake_rounded,
      warna: const Color(0xFFDB2777),
      builder: (_) => const KalkulatorUmurScreen(),
    ),
    MenuUtama(
      judul: 'Konversi Kalender',
      deskripsi: 'Penanggalan Hijriah, Weton Jawa, & Wuku Saka Bali',
      ikon: Icons.event_note_rounded,
      warna: const Color(0xFF059669),
      builder: (_) => const KonversiKalenderScreen(),
    ),
    MenuUtama(
      judul: 'Daftar Anggota Kelas',
      deskripsi: 'Lihat info kelas, Aslab, jadwal, & rekan di kelas praktikum',
      ikon: Icons.groups_rounded,
      warna: const Color(0xFF0284C7),
      builder: (_) => const DetailKelasPraktikanScreen(
        mataPraktikumId: 1,
        namaMataPraktikum: 'Pemrograman Mobile',
      ),
    ),
  ];
}

class ManualFeatureScreen extends StatelessWidget {
  final String judul;

  const ManualFeatureScreen({super.key, required this.judul});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Halaman manual $judul.\n\nModul lengkap dapat diintegrasikan nanti melalui menu ini.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
