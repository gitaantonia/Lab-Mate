import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/session_helper.dart';
import 'login_screen.dart';
import 'menu_utama.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    const pages = [HomeScreen(), StopwatchScreen(), BantuanScreen()];
    return Scaffold(
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Utama'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Stopwatch'),
          NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: 'Bantuan'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SessionData? session;
  @override
  void initState() {
    super.initState();
    SessionHelper.ambil().then((value) { if (mounted) setState(() => session = value); });
  }

  @override
  Widget build(BuildContext context) {
    final nama = session?.nama ?? 'Pengguna';
    return Scaffold(
      appBar: AppBar(title: const Text('LabMate')),
      body: Column(children: [
        ListTile(leading: CircleAvatar(child: Text(nama.isEmpty ? '?' : nama[0].toUpperCase())), title: Text('Halo, $nama'), subtitle: Text(session?.role == 'aslab' ? 'Asisten Laboratorium' : 'Praktikan')),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: semuaMenu.length,
          itemBuilder: (context, index) => Card(child: ListTile(
            leading: Icon(semuaMenu[index].ikon),
            title: Text(semuaMenu[index].judul),
            subtitle: Text(semuaMenu[index].deskripsi),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: semuaMenu[index].builder)),
          )),
        )),
      ]),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});
  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  String get display {
    final value = stopwatch.elapsed;
    return '${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}.${(value.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0')}';
  }
  void toggle() {
    setState(() {
      if (stopwatch.isRunning) { stopwatch.stop(); timer?.cancel(); } else { stopwatch.start(); timer = Timer.periodic(const Duration(milliseconds: 30), (_) => setState(() {})); }
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Stopwatch')),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(display, style: Theme.of(context).textTheme.displayMedium),
      const SizedBox(height: 24),
      Wrap(spacing: 12, children: [
        FilledButton.icon(onPressed: toggle, icon: Icon(stopwatch.isRunning ? Icons.pause : Icons.play_arrow), label: Text(stopwatch.isRunning ? 'Jeda' : 'Mulai')),
        OutlinedButton.icon(onPressed: () => setState(stopwatch.reset), icon: const Icon(Icons.restart_alt), label: const Text('Reset')),
      ]),
    ])),
  );
}

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});
  Future<void> logout(BuildContext context) async {
    await SessionHelper.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bantuan')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Cara menggunakan LabMate', style: Theme.of(context).textTheme.headlineSmall),
      const ListTile(leading: Icon(Icons.home), title: Text('Halaman Utama'), subtitle: Text('Pilih salah satu dari lima menu fitur.')),
      const ListTile(leading: Icon(Icons.timer), title: Text('Stopwatch'), subtitle: Text('Gunakan tombol Mulai, Jeda, dan Reset.')),
      const ListTile(leading: Icon(Icons.calendar_month), title: Text('Konversi Kalender'), subtitle: Text('Masukkan tanggal untuk melihat hasil konversi.')),
      const SizedBox(height: 20),
      OutlinedButton.icon(onPressed: () => logout(context), icon: const Icon(Icons.logout), label: const Text('Logout')),
    ]),
  );
}
