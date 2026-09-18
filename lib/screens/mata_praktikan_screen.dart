import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import 'nilai/komponen_bobot_screen.dart';

class MataPraktikumScreen extends StatefulWidget {
  final bool readOnly;

  const MataPraktikumScreen({super.key, this.readOnly = false});

  @override
  State<MataPraktikumScreen> createState() => _MataPraktikumScreenState();
}

class _MataPraktikumScreenState extends State<MataPraktikumScreen> {
  late Future<List<Map<String, dynamic>>> mataPraktikum;

  @override
  void initState() {
    super.initState();
    mataPraktikum = DBHelper.instance.getMataPraktikum();
  }

  void refresh() {
    setState(() {
      mataPraktikum = DBHelper.instance.getMataPraktikum();
    });
  }

  Future<void> bukaForm({Map<String, dynamic>? item}) async {
    final controller = TextEditingController();
    if (item != null) controller.text = item['nama'] as String;
    final nama = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item == null ? 'Tambah Mata Praktikum' : 'Edit Mata Praktikum',
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (nama == null || nama.isEmpty) return;
    if (item == null) {
      await DBHelper.instance.tambahMataPraktikum(nama);
    } else {
      await DBHelper.instance.updateMataPraktikum(item['id'] as int, nama);
    }
    if (mounted) refresh();
  }

  Future<void> hapus(int id) async {
    await DBHelper.instance.hapusMataPraktikum(id);
    if (mounted) refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: Text(
          widget.readOnly ? 'Daftar Mata Praktikum' : 'Mata Praktikum',
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () => bukaForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah'),
            ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: mataPraktikum,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada mata praktikum.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final nama = item['nama'] as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE3F2FD),
                    child: const Icon(
                      Icons.book_rounded,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  title: Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Mata praktikum aktif'),
                  trailing: widget.readOnly
                      ? const Icon(Icons.visibility_rounded, color: Colors.grey)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => KomponenBobotScreen(
                                      mataPraktikumId: item['id'] as int,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.tune_rounded, size: 16),
                              label: const Text('Bobot'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber.shade800,
                                side: BorderSide(color: Colors.amber.shade300),
                                backgroundColor: Colors.amber.shade50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => bukaForm(item: item),
                              icon: const Icon(Icons.edit_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue.shade50,
                                foregroundColor: const Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Hapus',
                              onPressed: () => hapus(item['id'] as int),
                              icon: const Icon(Icons.delete_outline_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
