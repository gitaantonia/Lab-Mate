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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF0D9488),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item == null ? 'Tambah Mata Praktikum' : 'Edit Mata Praktikum',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama Mata Praktikum',
            hintText: 'Contoh: Pemrograman Mobile',
            prefixIcon: Icon(Icons.edit_note_rounded),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
            ),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Mata Praktikum', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus mata praktikum ini? Semua komponen nilai dan praktikan terkait akan terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await DBHelper.instance.hapusMataPraktikum(id);
    if (mounted) refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.readOnly ? 'Daftar Mata Praktikum' : 'Kelola Mata Praktikum',
        ),
      ),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () => bukaForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Praktikum'),
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_stories_outlined,
                        size: 48,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Mata Praktikum',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tambahkan mata praktikum untuk memulai pengelolaan praktikum.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final nama = item['nama'] as String;
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
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF0D9488),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID Praktikum: #${item['id']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.readOnly)
                        const Icon(Icons.visibility_rounded, color: Colors.grey, size: 20)
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => KomponenBobotScreen(
                                      mataPraktikumId: item['id'] as int,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 14,
                                      color: Color(0xFFD97706),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Bobot',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              tooltip: 'Edit',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => bukaForm(item: item),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFEFF6FF),
                                foregroundColor: const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Hapus',
                              visualDensity: VisualDensity.compact,
                              onPressed: () => hapus(item['id'] as int),
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFFEF2F2),
                                foregroundColor: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
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
