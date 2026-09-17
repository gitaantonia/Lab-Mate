import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class PraktikanScreen extends StatefulWidget {
  const PraktikanScreen({super.key});

  @override
  State<PraktikanScreen> createState() => _PraktikanScreenState();
}

class _PraktikanScreenState extends State<PraktikanScreen> {
  late Future<List<Map<String, dynamic>>> praktikan;
  late Future<List<Map<String, dynamic>>> mataPraktikum;

  @override
  void initState() {
    super.initState();
    praktikan = DBHelper.instance.getPraktikan();
    mataPraktikum = DBHelper.instance.getMataPraktikum();
  }

  void refresh() {
    setState(() {
      praktikan = DBHelper.instance.getPraktikan();
      mataPraktikum = DBHelper.instance.getMataPraktikum();
    });
  }

  Future<void> bukaForm({Map<String, dynamic>? item}) async {
    final dataMata = await mataPraktikum;
    if (!mounted || dataMata.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buat mata praktikum terlebih dahulu.')),
        );
      }
      return;
    }

    final nimController = TextEditingController(text: item?['nim'] as String?);
    final namaController = TextEditingController(
      text: item?['nama'] as String?,
    );
    final tanggalController = TextEditingController(
      text: item?['tanggal_lahir'] as String?,
    );
    int mataId =
        item?['mata_praktikum_id'] as int? ?? dataMata.first['id'] as int;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Tambah Praktikan' : 'Edit Praktikan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: mataId,
                  decoration: const InputDecoration(
                    labelText: 'Mata Praktikum',
                  ),
                  items: dataMata
                      .map(
                        (mata) => DropdownMenuItem<int>(
                          value: mata['id'] as int,
                          child: Text(mata['nama'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => mataId = value);
                  },
                ),
                TextField(
                  controller: nimController,
                  decoration: const InputDecoration(labelText: 'NIM'),
                ),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: tanggalController,
                  decoration: const InputDecoration(labelText: 'Tanggal lahir'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (nimController.text.trim().isEmpty ||
                    namaController.text.trim().isEmpty ||
                    tanggalController.text.trim().isEmpty) {
                  return;
                }
                if (item == null) {
                  await DBHelper.instance.tambahPraktikan(
                    mataPraktikumId: mataId,
                    nim: nimController.text.trim(),
                    nama: namaController.text.trim(),
                    tanggalLahir: tanggalController.text.trim(),
                  );
                } else {
                  await DBHelper.instance.updatePraktikan(
                    id: item['id'] as int,
                    mataPraktikumId: mataId,
                    nim: nimController.text.trim(),
                    nama: namaController.text.trim(),
                    tanggalLahir: tanggalController.text.trim(),
                  );
                }
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    nimController.dispose();
    namaController.dispose();
    tanggalController.dispose();
    if (result == true && mounted) refresh();
  }

  Future<void> hapus(int id) async {
    await DBHelper.instance.hapusPraktikan(id);
    if (mounted) refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Praktikan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => bukaForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: praktikan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada praktikan.'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text(item['nama'] as String),
                subtitle: Text(item['nim'] as String),
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
