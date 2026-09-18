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
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Konfirmasi Logout'),
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
              backgroundColor: Colors.redAccent,
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
    final colorScheme = Theme.of(context).colorScheme;
    final username = _session?.username ?? 'Pengguna';
    final role = _session?.role == 'aslab' ? 'Asisten Laboratorium' : 'Praktikan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan & Info'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Identity Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primary,
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
                            Text(
                              'LabMate',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withAlpha(50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'v1.0.0',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
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
                            color: colorScheme.onPrimaryContainer.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Logged-in User Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              title: Text(
                _isLoadingSession ? 'Memuat profil...' : username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                _isLoadingSession ? '' : role,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              trailing: Chip(
                avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                label: const Text('Aktif', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.green.withAlpha(20),
                side: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section Header: Panduan Penggunaan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Panduan Penggunaan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // Accordion Guides
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildGuideTile(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Akses & Peran Pengguna',
                  subtitle: 'Perbedaan hak akses Aslab dan Praktikan',
                  content: '• Aslab (Asisten Laboratorium): Memiliki hak akses penuh untuk membuat, mengubah, dan menghapus (CRUD) data praktikum, praktikan, serta menginput nilai komponen.\n\n'
                      '• Praktikan: Hanya dapat melihat nilai akhir dan rekapitulasi miliknya sendiri (Read-only).',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  context,
                  icon: Icons.menu_book_outlined,
                  title: 'Kelola Praktikum & Praktikan',
                  subtitle: 'Navigasi dan manajemen data',
                  content: '• Kelola Data Praktikum: Digunakan oleh Aslab untuk mendaftarkan mata praktikum baru dan menentukan komponen bobot nilai (total bobot harus tepat 100%).\n\n'
                      '• Kelola Praktikan: Menambahkan mahasiswa praktikan baru. Sistem akan otomatis membuatkan akun login Praktikan (Username = NIM, Password default).',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  context,
                  icon: Icons.calculate_outlined,
                  title: 'Komputasi & Penilaian',
                  subtitle: 'Perhitungan nilai berbobot & kelompok',
                  content: '• Input Nilai: Nilai diinput per komponen praktikum. Komponen khusus "Project" dinilai paling akhir.\n\n'
                      '• Pembagian Kelompok: Dikelompokkan otomatis berdasarkan angka sebelum koma dari rata-rata nilai (Ganjil/Genap) dengan penyeimbangan selisih maksimal 1 anggota.',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  context,
                  icon: Icons.calendar_month_outlined,
                  title: 'Konversi Kalender & Umur',
                  subtitle: 'Hitung umur dan kalender budaya',
                  content: '• Konversi Tanggal Lahir: Menghitung umur presisi hingga tahun, bulan, hari, jam, menit, dan detik, serta tanggal kelahiran dalam kalender Hijriah.\n\n'
                      '• Kalender Budaya: Konversi tanggal masehi ke pasaran Weton Jawa (Legi, Pahing, Pon, Wage, Kliwon) dan siklus Pawukon Kalender Saka Bali.',
                ),
                const Divider(height: 1),
                _buildGuideTile(
                  context,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Tim Pengembang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
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
          ),
          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Logout Dari Aplikasi',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGuideTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExpansionTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withAlpha(220), height: 1.4),
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
        const Icon(Icons.person_outline, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                tugas,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
