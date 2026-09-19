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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item == null ? 'Tambah Praktikan' : 'Edit Praktikan',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  initialValue: mataId,
                  decoration: const InputDecoration(
                    labelText: 'Mata Praktikum',
                    prefixIcon: Icon(Icons.auto_stories_rounded),
                  ),
                  items: dataMata
                      .map(
                        (mata) => DropdownMenuItem<int>(
                          value: mata['id'] as int,
                          child: Text(
                            mata['nama'] as String,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'NIM (Nomor Induk Mahasiswa)',
                    hintText: 'Maksimal 9 digit angka',
                    prefixIcon: Icon(Icons.badge_outlined),
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
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama mahasiswa',
                    prefixIcon: Icon(Icons.person_outline_rounded),
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
                      initialDate: tanggalSaatIni ?? DateTime(2002, 1, 1),
                      firstDate: DateTime(1500),
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
                    labelText: 'Tanggal Lahir',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icon(Icons.calendar_month_rounded),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Praktikan', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text('Data praktikan dan akun loginnya akan dihapus.'),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.readOnly ? 'Daftar Praktikan' : 'Kelola Praktikan'),
      ),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () => bukaForm(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Tambah Praktikan'),
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
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
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_outline_rounded,
                        size: 48,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Praktikan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Klik tambah untuk mendaftarkan mahasiswa praktikan baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (!widget.readOnly) ...[
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => bukaForm(),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Tambah Praktikan'),
                      ),
                    ],
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
              final nama = item['nama'] as String? ?? 'Praktikan';
              final nim = item['nim'] as String? ?? '-';
              final tgl = item['tanggal_lahir'] as String? ?? '-';

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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                            fontSize: 16,
                          ),
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
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    nim,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tgl,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
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
