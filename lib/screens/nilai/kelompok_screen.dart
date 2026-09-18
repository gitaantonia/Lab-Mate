import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../utils/kelompok_helper.dart';

class KelompokScreen extends StatefulWidget {
  const KelompokScreen({super.key});

  @override
  State<KelompokScreen> createState() => _KelompokScreenState();
}

class _KelompokScreenState extends State<KelompokScreen> {
  final DBHelper dbHelper = DBHelper.instance;

  List<Map<String, dynamic>> mataPraktikum = [];
  List<Map<String, dynamic>> praktikan = [];

  List<List<String>> kelompok = [];

  int? selectedMataPraktikumId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMataPraktikum();
  }

  Future<void> _loadMataPraktikum() async {
    final data = await dbHelper.getMataPraktikum();

    setState(() {
      mataPraktikum = data;
    });
  }

  Future<void> _loadPraktikan(int mataPraktikumId) async {
    setState(() {
      isLoading = true;
      praktikan = [];
      kelompok = [];
    });

    final data =
        await dbHelper.getPraktikanByMataPraktikum(mataPraktikumId);

    setState(() {
      praktikan = data;
      isLoading = false;
    });
  }

  void _bagiKelompok() {
    if (praktikan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada data praktikan.'),
        ),
      );
      return;
    }

    final ids = praktikan
        .map((p) => p['id'].toString())
        .toList();

    final hasil = KelompokHelper.bagiKelompok(
      praktikanIds: ids,
      minAnggota: 3,
      maxAnggota: 4,
    );

    if (hasil.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jumlah praktikan tidak dapat dibagi menjadi kelompok 3-4 orang.',
          ),
        ),
      );
      return;
    }

    setState(() {
      kelompok = hasil;
    });
  }

  Future<void> _simpanKelompok() async {
    if (kelompok.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bagi kelompok terlebih dahulu.'),
        ),
      );
      return;
    }

    for (int i = 0; i < kelompok.length; i++) {
      final namaKelompok = KelompokHelper.buatNamaKelompok(i);

      for (final id in kelompok[i]) {
        await dbHelper.updateKelompok(
          praktikanId: int.parse(id),
          kelompok: namaKelompok,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembagian kelompok berhasil disimpan.'),
      ),
    );

    if (selectedMataPraktikumId != null) {
      await _loadPraktikan(selectedMataPraktikumId!);
    }
  }

  Map<String, dynamic>? _getPraktikanById(String id) {
    for (final p in praktikan) {
      if (p['id'].toString() == id) {
        return p;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembagian Kelompok'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // MATA PRAKTIKUM
            // =========================

            const Text(
              'Mata Praktikum',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              value: selectedMataPraktikumId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pilih Mata Praktikum',
              ),

              items: mataPraktikum.map((mata) {
                return DropdownMenuItem<int>(
                  value: mata['id'] as int,
                  child: Text(
                    mata['nama'].toString(),
                  ),
                );
              }).toList(),

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedMataPraktikumId = value;
                });

                _loadPraktikan(value);
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // DAFTAR PRAKTIKAN
            // =========================

            const Text(
              'Daftar Praktikan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : praktikan.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada praktikan.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: praktikan.length,
                          itemBuilder: (context, index) {
                            final p = praktikan[index];

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    '${index + 1}',
                                  ),
                                ),
                                title: Text(
                                  p['nama'].toString(),
                                ),
                                subtitle: Text(
                                  'NIM: ${p['nim']}',
                                ),
                                trailing: Text(
                                  p['kelompok']?.toString() ?? '-',
                                ),
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 12),

            // =========================
            // TOMBOL BAGI KELOMPOK
            // =========================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedMataPraktikumId == null
                    ? null
                    : _bagiKelompok,
                icon: const Icon(Icons.groups),
                label: const Text(
                  'Bagi Kelompok',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // HASIL KELOMPOK
            // =========================

            if (kelompok.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: kelompok.length,
                  itemBuilder: (context, index) {
                    final anggota = kelompok[index];

                    return Card(
                      child: ExpansionTile(
                        title: Text(
                          KelompokHelper.buatNamaKelompok(index),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '${anggota.length} anggota',
                        ),

                        children: anggota.map((id) {
                          final p = _getPraktikanById(id);

                          if (p == null) {
                            return const SizedBox();
                          }

                          return ListTile(
                            leading: const Icon(
                              Icons.person,
                            ),
                            title: Text(
                              p['nama'].toString(),
                            ),
                            subtitle: Text(
                              'NIM: ${p['nim']}',
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

            // =========================
            // SIMPAN
            // =========================

            if (kelompok.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _simpanKelompok,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Simpan Pembagian Kelompok',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}