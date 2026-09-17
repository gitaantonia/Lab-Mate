import 'package:flutter/material.dart';
import 'mata_praktikan_screen.dart';
import 'praktikan/praktikan_screen.dart';

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
        deskripsi: 'Tempat integrasi modul komputasi',
        ikon: Icons.calculate,
        builder: (_) => const ManualFeatureScreen(judul: 'Komputasi Nilai'),
      ),
      MenuUtama(
        judul: 'Kalkulator Umur',
        deskripsi: 'Tempat integrasi kalkulator umur',
        ikon: Icons.cake,
        builder: (_) => const ManualFeatureScreen(judul: 'Kalkulator Umur'),
      ),
      MenuUtama(
        judul: 'Konversi Kalender',
        deskripsi: 'Tempat integrasi kalender Hijriah, Weton, dan Saka Bali',
        ikon: Icons.event,
        builder: (_) => const ManualFeatureScreen(judul: 'Konversi Kalender'),
      ),
    ];
  }

  return [
    MenuUtama(
      judul: 'Daftar Anggota',
      deskripsi: 'Lihat data praktikan secara read-only',
      ikon: Icons.groups,
      builder: (_) => const PraktikanScreen(readOnly: true),
    ),
    MenuUtama(
      judul: 'Kelola Data Praktikum',
      deskripsi: 'Lihat mata praktikum secara read-only',
      ikon: Icons.folder_shared,
      builder: (_) => const MataPraktikumScreen(readOnly: true),
    ),
    MenuUtama(
      judul: 'Komputasi Nilai',
      deskripsi: 'Tempat integrasi modul komputasi',
      ikon: Icons.calculate,
      builder: (_) => const ManualFeatureScreen(judul: 'Komputasi Nilai'),
    ),
    MenuUtama(
      judul: 'Kalkulator Umur',
      deskripsi: 'Tempat integrasi kalkulator umur',
      ikon: Icons.cake,
      builder: (_) => const ManualFeatureScreen(judul: 'Kalkulator Umur'),
    ),
    MenuUtama(
      judul: 'Konversi Kalender',
      deskripsi: 'Tempat integrasi kalender Hijriah, Weton, dan Saka Bali',
      ikon: Icons.event,
      builder: (_) => const ManualFeatureScreen(judul: 'Konversi Kalender'),
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
