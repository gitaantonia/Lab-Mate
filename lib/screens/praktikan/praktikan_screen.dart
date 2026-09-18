import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../database/database_helper.dart';
import '../../utils/tanggal_helper.dart';
import '../mata_praktikan_screen.dart';

class PraktikanScreen extends StatefulWidget {
  final bool readOnly;

  const PraktikanScreen({super.key, this.readOnly = false});

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

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.year.toString().padLeft(4, '0')}-'
        '${tanggal.month.toString().padLeft(2, '0')}-'
        '${tanggal.day.toString().padLeft(2, '0')}';
  }

  Future<void> bukaForm({Map<String, dynamic>? item}) async {
    final dataMata = await mataPraktikum;
    if (!mounted || dataMata.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Buat mata praktikum terlebih dahulu.'),
            action: SnackBarAction(
              label: 'Buat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MataPraktikumScreen(),
                  ),
                );
              },
            ),
          ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: mataId,
                  decoration: const InputDecoration(
                    labelText: 'Mata Praktikum',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 14),
                TextField(
                  controller: nimController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'NIM',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: namaController,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: tanggalController,
                  readOnly: true,
                  onTap: () async {
                    final tanggalSaatIni = parseTanggalLahir(
                      tanggalController.text,
                    );
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tanggalSaatIni ?? DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      helpText: 'PILIH TANGGAL LAHIR',
                    );
                    if (picked != null) {
                      setDialogState(
                        () => tanggalController.text = _formatTanggal(picked),
                      );
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tanggal lahir',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final nim = nimController.text.trim();
                final nama = namaController.text.trim();
                final tanggalLahir = tanggalController.text.trim();

                if (nim.isEmpty || !RegExp(r'^\d+$').hasMatch(nim)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('NIM hanya boleh berisi angka.'),
                    ),
                  );
                  return;
                }
                if (nama.isEmpty || !RegExp(r'^[a-zA-Z ]+$').hasMatch(nama)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama hanya boleh berisi huruf.'),
                    ),
                  );
                  return;
                }
                if (parseTanggalLahir(tanggalLahir) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih tanggal lahir yang valid.'),
                    ),
                  );
                  return;
                }
                try {
                  if (item == null) {
                    await DBHelper.instance.tambahPraktikan(
                      mataPraktikumId: mataId,
                      nim: nim,
                      nama: nama,
                      tanggalLahir: tanggalLahir,
                    );
                  } else {
                    await DBHelper.instance.updatePraktikan(
                      id: item['id'] as int,
                      mataPraktikumId: mataId,
                      nim: nim,
                      nama: nama,
                      tanggalLahir: tanggalLahir,
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menyimpan praktikan: $error'),
                      ),
                    );
                  }
                  return;
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
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus praktikan?'),
        content: const Text('Data praktikan dan akun loginnya akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    try {
      await DBHelper.instance.hapusPraktikan(id);
      if (mounted) refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus praktikan: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Data Praktikan' : 'Praktikan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () => bukaForm(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Tambah'),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum ada praktikan.\nKlik tambah untuk menambahkan data baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    if (!widget.readOnly)
                      FilledButton.icon(
                        onPressed: () => bukaForm(),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Tambah Praktikan'),
                      ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
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
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE3F2FD),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  title: Text(
                    item['nama'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${item['nim']} • ${item['tanggal_lahir'] ?? '-'}',
                  ),
                  trailing: widget.readOnly
                      ? const Icon(Icons.visibility_rounded, color: Colors.grey)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
