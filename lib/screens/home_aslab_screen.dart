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
        'subtitle': 'Tambah, edit, dan kelola mata praktikum & bobot',
        'icon': Icons.auto_stories_rounded,
        'color': const Color(0xFF0D9488),
        'screen': const MataPraktikumScreen(),
      },
      {
        'title': 'Kelola Praktikan',
        'subtitle': 'Tambah, edit, dan hapus data praktikan',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF2563EB),
        'screen': const PraktikanScreen(),
      },
      {
        'title': 'Daftar Praktikan',
        'subtitle': 'Mode read-only untuk melihat data praktikan',
        'icon': Icons.visibility_rounded,
        'color': const Color(0xFF0284C7),
        'screen': const PraktikanScreen(readOnly: true),
      },
      {
        'title': 'Komputasi Nilai',
        'subtitle': 'Input nilai dan hitung nilai akhir',
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFF7C3AED),
        'screen': const NilaiInputScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Aslab'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Portal Asisten Lab',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola data praktikum, praktikan, dan penilaian secara terstruktur.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Layanan Utama Aslab',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...menu.map((item) {
            final screen = item['screen'] as Widget;
            final color = item['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => screen),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['subtitle'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
