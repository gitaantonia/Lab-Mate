import 'package:flutter/material.dart';
import 'nilai/input_nilai_screen.dart';

class MenuUtama {
  final String judul;
  final String deskripsi;
  final IconData ikon;
  final WidgetBuilder builder;

  const MenuUtama({required this.judul, required this.deskripsi, required this.ikon, required this.builder});
}

final List<MenuUtama> semuaMenu = [
  MenuUtama(judul: 'Daftar Anggota', deskripsi: 'Tempat integrasi layar daftar anggota', ikon: Icons.groups, builder: (_) => const ManualFeatureScreen(judul: 'Daftar Anggota')),
  MenuUtama(judul: 'Kelola Data Praktikum', deskripsi: 'Tempat integrasi modul CRUD', ikon: Icons.folder_shared, builder: (_) => const ManualFeatureScreen(judul: 'Kelola Data Praktikum')),
  MenuUtama(judul: 'Komputasi Nilai', deskripsi: 'Tempat integrasi modul komputasi', ikon: Icons.calculate, builder: (_) => const NilaiInputScreen()),
  MenuUtama(judul: 'Kalkulator Umur', deskripsi: 'Tempat integrasi kalkulator umur', ikon: Icons.cake, builder: (_) => const ManualFeatureScreen(judul: 'Kalkulator Umur')),
  MenuUtama(judul: 'Konversi Kalender', deskripsi: 'Tempat integrasi kalender Hijriah, Weton, dan Saka Bali', ikon: Icons.event, builder: (_) => const ManualFeatureScreen(judul: 'Konversi Kalender')),
];

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
