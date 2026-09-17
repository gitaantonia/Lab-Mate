import 'package:flutter/material.dart';
import '../utils/session_helper.dart';
import 'menu_utama.dart';
import 'stopwatch_screen.dart';
import 'bantuan_screen.dart';
import 'profil_screen.dart';

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
  @override
  void initState() {
    super.initState();
    SessionHelper.ambil().then((value) {
      if (mounted) setState(() => session = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nama = session?.nama ?? 'Pengguna';
    final menu = getSemuaMenu(widget.role);

    return Scaffold(
      appBar: AppBar(title: const Text('LabMate')),
      body: Column(
        children: [
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menu.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  leading: Icon(menu[index].ikon),
                  title: Text(menu[index].judul),
                  subtitle: Text(menu[index].deskripsi),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: menu[index].builder),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
