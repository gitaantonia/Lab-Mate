import 'package:flutter/material.dart';

import 'mata_praktikan_screen.dart';
import 'praktikan/praktikan_screen.dart';
import 'nilai/input_nilai_screen.dart';

class HomeAslabScreen extends StatelessWidget {
  const HomeAslabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = [
      {
        'title': 'Kelola Mata Praktikum',
        'subtitle': 'Tambah, edit, dan hapus mata praktikum',
        'icon': Icons.school_rounded,
        'screen': const MataPraktikumScreen(),
      },
      {
        'title': 'Kelola Praktikan',
        'subtitle': 'Tambah, edit, dan hapus data praktikan',
        'icon': Icons.people_alt_rounded,
        'screen': const PraktikanScreen(),
      },
      {
        'title': 'Daftar Praktikan',
        'subtitle': 'Mode read-only untuk melihat data praktikan',
        'icon': Icons.visibility_rounded,
        'screen': const PraktikanScreen(readOnly: true),
      },
      {
        'title': 'Komputasi Nilai',
        'subtitle': 'Input nilai dan hitung nilai akhir',
        'icon': Icons.calculate_rounded,
        'screen': const NilaiInputScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home Aslab')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Selamat datang, Aslab',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola data praktikum sesuai tugas modul CRUD.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          ...menu.map((item) {
            final screen = item['screen'] as Widget;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(item['icon'] as IconData, color: Colors.blue),
                ),
                title: Text(item['title'] as String),
                subtitle: Text(item['subtitle'] as String),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
