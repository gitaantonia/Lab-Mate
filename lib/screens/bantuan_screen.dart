import 'package:flutter/material.dart';
import '../utils/session_helper.dart';
import 'login_screen.dart';

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  SessionData? _session;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final data = await SessionHelper.ambil();
    if (mounted) {
      setState(() {
        _session = data;
        _isLoadingSession = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Konfirmasi Logout', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi LabMate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SessionHelper.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _session?.username ?? 'Pengguna';
    final role = _session?.role == 'aslab' ? 'Asisten Laboratorium' : 'Mahasiswa Praktikan';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pusat Bantuan & Info'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // App Identity Header Card
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.science_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'LabMate',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'v1.0.0',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Asisten Digital Manajemen & Penilaian Praktikum Laboratorium',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Logged-in User Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingSession ? 'Memuat profil...' : username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        _isLoadingSession ? '' : role,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Color(0xFF059669)),
                      SizedBox(width: 4),
                      Text(
                        'Aktif',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Header: Panduan Penggunaan
          const Text(
            'Panduan Penggunaan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          // Accordion Guides
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildGuideTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Akses & Peran Pengguna',
                  subtitle: 'Perbedaan hak akses Aslab dan Praktikan',
                  content: '• Aslab (Asisten Laboratorium): Memiliki hak akses penuh untuk membuat, mengubah, dan menghapus (CRUD) data praktikum, praktikan, serta menginput nilai komponen.\n\n'
                      '• Praktikan: Hanya dapat melihat nilai akhir dan rekapitulasi miliknya sendiri (Read-only).',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Kelola Praktikum & Praktikan',
                  subtitle: 'Navigasi dan manajemen data',
                  content: '• Kelola Data Praktikum: Digunakan oleh Aslab untuk mendaftarkan mata praktikum baru dan menentukan komponen bobot nilai (total bobot harus tepat 100%).\n\n'
                      '• Kelola Praktikan: Menambahkan mahasiswa praktikan baru. Sistem akan otomatis membuatkan akun login Praktikan (Username = NIM, Password default).',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  icon: Icons.calculate_outlined,
                  title: 'Komputasi & Penilaian',
                  subtitle: 'Perhitungan nilai berbobot & kelompok',
                  content: '• Input Nilai: Nilai diinput per komponen praktikum. Komponen khusus "Project" dinilai paling akhir.\n\n'
                      '• Pembagian Kelompok: Dikelompokkan otomatis berdasarkan angka sebelum koma dari rata-rata nilai (Ganjil/Genap) dengan format 3-4 orang per kelompok.',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'Konversi Kalender & Umur',
                  subtitle: 'Hitung umur dan kalender budaya',
                  content: '• Konversi Tanggal Lahir: Menghitung umur presisi hingga tahun, bulan, hari, jam, menit, dan detik, serta tanggal kelahiran dalam kalender Hijriah.\n\n'
                      '• Kalender Budaya: Konversi tanggal masehi ke pasaran Weton Jawa (Legi, Pahing, Pon, Wage, Kliwon) dan siklus Pawukon Kalender Saka Bali.',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  icon: Icons.timer_outlined,
                  title: 'Stopwatch Laboratorium',
                  subtitle: 'Pengukur durasi modul & praktikum',
                  content: '• Gunakan tombol Mulai, Jeda, dan Reset untuk mengatur stopwatch.\n\n'
                      '• Tekan tombol "Lap" saat stopwatch berjalan untuk mencatat interval atau waktu penyelesaian modul praktikan. Sistem otomatis menandai lap tercepat dan terlambat.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Header: Anggota Tim Pengembang
          const Text(
            'Tim Pengembang',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                _DeveloperMemberTile(
                  nama: 'Gita Antonia Sipayung',
                  tugas: 'Database (SQLite), Login, Session, & Navigation',
                ),
                Divider(height: 16),
                _DeveloperMemberTile(
                  nama: 'Lucy Katarina Naibaho',
                  tugas: 'CRUD Mata Praktikum & Kelola Praktikan',
                ),
                Divider(height: 16),
                _DeveloperMemberTile(
                  nama: 'Serena Luna Halim',
                  tugas: 'Komputasi Nilai Akhir, Pembobotan Nilai, Rata-rata & Kelompok',
                ),
                Divider(height: 16),
                _DeveloperMemberTile(
                  nama: 'Gevinta Aprilia Putri',
                  tugas: 'Konversi Kalender (Hijriah/Weton/Saka), Stopwatch, & Bantuan',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              label: const Text(
                'Logout Dari Aplikasi',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                backgroundColor: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGuideTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String content,
  }) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF0F172A)),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _DeveloperMemberTile extends StatelessWidget {
  final String nama;
  final String tugas;

  const _DeveloperMemberTile({
    required this.nama,
    required this.tugas,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF2563EB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 2),
              Text(
                tugas,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
