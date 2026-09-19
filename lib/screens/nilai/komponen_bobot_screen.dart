import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class KomponenBobotScreen extends StatefulWidget {
  final int? mataPraktikumId;

  const KomponenBobotScreen({super.key, this.mataPraktikumId});

  @override
  State<KomponenBobotScreen> createState() => _KomponenBobotScreenState();
}

class _KomponenBobotScreenState extends State<KomponenBobotScreen> {
  late Future<List<Map<String, dynamic>>> _mataPraktikumFuture;
  late Future<List<Map<String, dynamic>>> _komponenFuture;
  int? _selectedMataPraktikumId;

  @override
  void initState() {
    super.initState();
    _mataPraktikumFuture = DBHelper.instance.getMataPraktikum();
    _selectedMataPraktikumId = widget.mataPraktikumId;
    _komponenFuture = _loadKomponen();
  }

  Future<List<Map<String, dynamic>>> _loadKomponen() async {
    final id = _selectedMataPraktikumId;
    if (id == null) {
      return const [];
    }
    return DBHelper.instance.getKomponenBobot(id);
  }

  void _refresh() {
    setState(() {
      _komponenFuture = _loadKomponen();
    });
  }

  Future<void> _showForm({Map<String, dynamic>? item}) async {
    final namaController = TextEditingController(
      text: item != null ? (item['nama_komponen'] as String? ?? '') : '',
    );
    final bobotController = TextEditingController(
      text: item != null ? ((item['bobot'] as num?)?.toString() ?? '') : '',
    );

    if (_selectedMataPraktikumId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mata praktikum terlebih dahulu')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              item == null ? 'Tambah Komponen' : 'Edit Komponen',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Komponen',
                  hintText: 'Contoh: Tugas / Kuis / UTS / UAS',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bobotController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Bobot Persentase (%)',
                  hintText: 'Contoh: 20',
                  prefixIcon: Icon(Icons.pie_chart_outline_rounded),
                ),
              ),
            ],
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
              backgroundColor: const Color(0xFFD97706),
            ),
            onPressed: () {
              final nama = namaController.text.trim();
              final bobotText = bobotController.text.trim();
              final bobot = double.tryParse(bobotText);

              if (nama.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama komponen tidak boleh kosong'),
                  ),
                );
                return;
              }

              if (bobot == null || bobot <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bobot harus lebih dari 0')),
                );
                return;
              }

              Navigator.pop(context, {'nama': nama, 'bobot': bobot});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    namaController.dispose();
    bobotController.dispose();

    if (result == null) return;

    final nama = result['nama'] as String;
    final bobot = (result['bobot'] as double).toDouble();
    final komponenSaatIni = await DBHelper.instance.getKomponenBobot(
      _selectedMataPraktikumId!,
    );
    final totalBobotSaatIni = komponenSaatIni.fold<double>(0, (total, data) {
      return total + ((data['bobot'] as num?)?.toDouble() ?? 0.0);
    });
    final bobotLama = item == null
        ? 0.0
        : ((item['bobot'] as num?)?.toDouble() ?? 0.0);
    final totalBobotSetelahSimpan = totalBobotSaatIni - bobotLama + bobot;

    if (totalBobotSetelahSimpan > 100.01) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Total bobot tidak boleh lebih dari 100%. '
              'Total setelah disimpan: '
              '${totalBobotSetelahSimpan.toStringAsFixed(2)}%',
            ),
          ),
        );
      }
      return;
    }

    if (item == null) {
      await DBHelper.instance.tambahKomponenBobot(
        mataPraktikumId: _selectedMataPraktikumId!,
        namaKomponen: nama,
        bobot: bobot,
      );
    } else {
      await DBHelper.instance.updateKomponenBobot(
        id: item['id'] as int,
        namaKomponen: nama,
        bobot: bobot,
      );
    }

    if (mounted) {
      _refresh();
    }
  }

  Future<void> _hapus(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Komponen', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus komponen bobot nilai ini?',
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

    await DBHelper.instance.hapusKomponenBobot(id);
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Komponen Bobot Nilai'),
      ),
      floatingActionButton: _selectedMataPraktikumId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Komponen'),
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mataPraktikumFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat mata praktikum: ${snapshot.error}'),
            );
          }

          final mataPraktikumList = snapshot.data ?? [];
          if (mataPraktikumList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_stories_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Mata Praktikum',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tambahkan mata praktikum terlebih dahulu untuk mengonfigurasi komponen bobot.',
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

          _selectedMataPraktikumId ??= mataPraktikumList.first['id'] as int;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _komponenFuture,
            builder: (context, komponenSnapshot) {
              if (komponenSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (komponenSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat komponen bobot: ${komponenSnapshot.error}',
                  ),
                );
              }

              final items = komponenSnapshot.data ?? [];
              final totalBobot = items.fold<double>(0, (sum, item) {
                final bobot = (item['bobot'] as num?)?.toDouble() ?? 0.0;
                return sum + bobot;
              });

              final is100Percent = (totalBobot - 100).abs() < 0.01;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                children: [
                  // Dropdown Mata Praktikum Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Mata Praktikum',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedMataPraktikumId,
                          items: mataPraktikumList.map((item) {
                            return DropdownMenuItem<int>(
                              value: item['id'] as int,
                              child: Text(item['nama'] as String, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedMataPraktikumId = value;
                              _komponenFuture = _loadKomponen();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Total Bobot Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: is100Percent ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: is100Percent ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  is100Percent ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                  color: is100Percent ? const Color(0xFF059669) : const Color(0xFFD97706),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Total Akumulasi Bobot',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${totalBobot.toStringAsFixed(0)}% / 100%',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: is100Percent ? const Color(0xFF059669) : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (totalBobot / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade200,
                            color: is100Percent ? const Color(0xFF059669) : const Color(0xFFD97706),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          is100Percent
                              ? 'Total bobot telah valid dan pas 100%.'
                              : 'Total bobot harus tepat 100% untuk komputasi nilai yang akurat.',
                          style: TextStyle(
                            fontSize: 12,
                            color: is100Percent ? const Color(0xFF047857) : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Daftar Komponen Penilaian',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum Ada Komponen Bobot',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tambahkan komponen seperti Tugas, Kuis, UTS, UAS, atau Project.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
                            ),
                            onPressed: () => _showForm(),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Tambah Komponen'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...items.map((item) {
                      final nama = item['nama_komponen'] as String? ?? 'Komponen';
                      final bobot = (item['bobot'] as num?)?.toDouble() ?? 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.assignment_rounded,
                                  color: Color(0xFFD97706),
                                  size: 20,
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
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Bobot Komponen: ${bobot.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _showForm(item: item),
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
                                    onPressed: () => _hapus(item['id'] as int),
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
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
