import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class MataPraktikumScreen extends StatefulWidget {
  const MataPraktikumScreen({super.key});

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
      appBar: AppBar(title: const Text('Mata Praktikum')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => bukaForm(),
        child: const Icon(Icons.add),
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
            return const Center(child: Text('Belum ada mata praktikum.'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text(item['nama'] as String),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => bukaForm(item: item),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Hapus',
                      onPressed: () => hapus(item['id'] as int),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
