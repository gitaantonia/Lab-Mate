import 'package:flutter/material.dart';
// [AKSES DATABASE - READ ONLY] Impor DBHelper untuk mengambil kelas praktikum yang diikuti pada Carousel Praktikan
import '../database/database_helper.dart';
import '../utils/session_helper.dart';
import 'menu_utama.dart';
import 'stopwatch_screen.dart';
import 'bantuan_screen.dart';
import 'profil_screen.dart';
import 'detail_kelas_praktikan_screen.dart';

class MainShell extends StatefulWidget {
  final String role;

  const MainShell({super.key, required this.role});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(role: widget.role),
      const StopwatchScreen(),
      const BantuanScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Utama',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Bantuan',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SessionData? session;
  List<Map<String, dynamic>> mataPraktikumList = [];
  bool isLoadingMata = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sess = await SessionHelper.ambil();
    if (mounted) setState(() => session = sess);

    if (widget.role == 'praktikan') {
      setState(() => isLoadingMata = true);
      try {
        // [AKSES DATABASE - READ ONLY] Mengambil daftar mata praktikum untuk carousel kelas praktikan
        final data = await DBHelper.instance.getMataPraktikum();
        if (mounted) {
          setState(() {
            mataPraktikumList = data;
          });
        }
      } catch (e) {
        debugPrint('Gagal memuat mata praktikum: $e');
      } finally {
        if (mounted) setState(() => isLoadingMata = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nama = session?.nama ?? 'Pengguna';
    final menu = getSemuaMenu(widget.role);

    // Data dummy jadwal & aslab untuk variasi tampilan carousel
    final List<Map<String, String>> sampleMeta = [
      {'aslab': 'Tim Aslab Serena & Gita', 'jadwal': 'Senin, 08:00 - 10:30 WIB'},
      {'aslab': 'Tim Aslab Amalia & Budi', 'jadwal': 'Rabu, 10:00 - 12:30 WIB'},
      {'aslab': 'Tim Aslab Doni & Rizky', 'jadwal': 'Jumat, 13:30 - 16:00 WIB'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('LabMate')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Bar
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  nama.isEmpty ? '?' : nama[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
              ),
              title: Text('Halo, $nama'),
              subtitle: Text(
                widget.role == 'aslab' ? 'Asisten Laboratorium' : 'Praktikan',
              ),
              trailing: const Icon(Icons.person_outline),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilScreen()),
                );
              },
            ),
            const Divider(height: 1),

            // CAROUSEL KELAS PRAKTIKUM (Khusus Tampilan Praktikan)
            if (widget.role == 'praktikan') ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kelas Praktikum Saya',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Text(
                      'Geser ke samping ➔',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              if (isLoadingMata)
                const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (mataPraktikumList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey.shade400),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Belum ada kelas praktikum yang diikuti.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 165,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: mataPraktikumList.length,
                    itemBuilder: (context, index) {
                      final item = mataPraktikumList[index];
                      final meta = sampleMeta[index % sampleMeta.length];
                      final namaKelas = item['nama']?.toString() ?? 'Praktikum';
                      final mpId = item['id'] as int;

                      final List<List<Color>> gradients = [
                        [Colors.blue.shade800, Colors.indigo.shade600],
                        [Colors.teal.shade700, Colors.cyan.shade800],
                        [Colors.deepPurple.shade700, Colors.purple.shade600],
                      ];
                      final bgGradient = gradients[index % gradients.length];

                      return Container(
                        width: 280,
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailKelasPraktikanScreen(
                                    mataPraktikumId: mpId,
                                    namaMataPraktikum: namaKelas,
                                    namaAslab: meta['aslab']!,
                                    jadwal: meta['jadwal']!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: bgGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Kelas Terdaftar',
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        namaKelas,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Aslab: ${meta['aslab']}',
                                        style: const TextStyle(fontSize: 12, color: Colors.white90),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          meta['jadwal']!,
                                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Menu & Fitur Praktikan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // LIST MENU UTAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: menu.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(item.ikon, color: Colors.blue.shade700),
                      title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(item.deskripsi),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: item.builder),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
