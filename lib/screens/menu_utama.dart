import 'package:flutter/material.dart';
import 'mata_praktikan_screen.dart';
import 'praktikan/praktikan_screen.dart';
import 'nilai/input_nilai_screen.dart';
import 'nilai/kelompok_screen.dart';
import 'nilai/lihat_nilai_screen.dart';
import 'nilai/rekap_nilai_screen.dart';
import 'kalkulator_umur_screen.dart';
import 'konversi_kalender_screen.dart';

class MenuUtama {
  final String judul;
  final String deskripsi;
  final IconData ikon;
  final WidgetBuilder builder;

  const MenuUtama({
    required this.judul,
    required this.deskripsi,
    required this.ikon,
    required this.builder,
  });
}

List<MenuUtama> getSemuaMenu(String role) {
  if (role == 'aslab') {
    return [
      MenuUtama(
        judul: 'Daftar Anggota',
        deskripsi: 'Tambah, edit, dan hapus data praktikan',
        ikon: Icons.groups,
        builder: (_) => const PraktikanScreen(),
      ),
      MenuUtama(
        judul: 'Kelola Data Praktikum',
        deskripsi: 'Tambah, edit, dan hapus mata praktikum',
        ikon: Icons.folder_shared,
        builder: (_) => const MataPraktikumScreen(),
      ),
      MenuUtama(
        judul: 'Komputasi Nilai',
        deskripsi: 'Input nilai praktikan & komputasi nilai akhir',
        ikon: Icons.calculate,
        builder: (_) => const NilaiInputScreen(),
      ),
      MenuUtama(
        judul: 'Kelompok Praktikum',
        deskripsi: 'Lihat dan kelola kelompok praktikum',
        ikon: Icons.group,
        builder: (_) => const KelompokScreen(),
      ),
      MenuUtama(
        judul: 'Rekap Nilai Praktikan',
        deskripsi: 'Lihat rekap nilai seluruh praktikan berdasarkan mata praktikum',
        ikon: Icons.table_chart,
        builder: (_) => const RekapNilaiScreen(),
      ),
      MenuUtama(
        judul: 'Kalkulator Umur',
        deskripsi: 'Hitung presisi usia dari tanggal acuan mana saja',
        ikon: Icons.cake,
        builder: (_) => const KalkulatorUmurScreen(),
      ),
      MenuUtama(
        judul: 'Konversi Kalender',
        deskripsi: 'Penanggalan Hijriah, Weton Jawa, dan Wuku Saka Bali',
        ikon: Icons.event,
        builder: (_) => const KonversiKalenderScreen(),
      ),
    ];
  }

  return [
    MenuUtama(
      judul: 'Lihat Nilai Saya',
      deskripsi: 'Cek rincian skor komponen dan Nilai Akhir + Grade',
      ikon: Icons.calculate,
      builder: (_) => const LihatNilaiScreen(),
    ),
    MenuUtama(
      judul: 'Kalkulator Umur',
      deskripsi: 'Hitung presisi usia dari tanggal acuan mana saja',
      ikon: Icons.cake,
      builder: (_) => const KalkulatorUmurScreen(),
    ),
    MenuUtama(
      judul: 'Konversi Kalender',
      deskripsi: 'Penanggalan Hijriah, Weton Jawa, dan Wuku Saka Bali',
      ikon: Icons.event,
      builder: (_) => const KonversiKalenderScreen(),
    ),
    MenuUtama(
      judul: 'Daftar Anggota',
      deskripsi: 'Lihat data rekan praktikan secara read-only',
      ikon: Icons.groups,
      builder: (_) => const PraktikanScreen(readOnly: true),
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
