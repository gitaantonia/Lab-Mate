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
    if (!mounted) return;

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

    final data = await dbHelper.getPraktikanByMataPraktikum(mataPraktikumId);
    if (!mounted) return;

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

    final ids = praktikan.map((p) => p['id'].toString()).toList();

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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembagian kelompok berhasil disimpan.'),
        backgroundColor: Color(0xFF059669),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pembagian Kelompok'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // MATA PRAKTIKUM CARD
            // =========================
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
                    initialValue: selectedMataPraktikumId,
                    hint: const Text('Pilih Mata Praktikum'),
                    items: mataPraktikum.map((mata) {
                      return DropdownMenuItem<int>(
                        value: mata['id'] as int,
                        child: Text(mata['nama'].toString(), overflow: TextOverflow.ellipsis),
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // ACTION BUTTONS
            // =========================
            if (selectedMataPraktikumId != null) ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: selectedMataPraktikumId == null || praktikan.isEmpty
                          ? null
                          : _bagiKelompok,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text('Bagi Otomatis'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (kelompok.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _simpanKelompok,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Simpan Hasil'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],

            // =========================
            // HASIL KELOMPOK
            // =========================
            if (kelompok.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.groups_rounded, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Hasil Pembagian (${kelompok.length} Kelompok)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...List.generate(kelompok.length, (index) {
                final anggota = kelompok[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.group_rounded, color: Color(0xFF0284C7), size: 20),
                    ),
                    title: Text(
                      KelompokHelper.buatNamaKelompok(index),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      '${anggota.length} Mahasiswa (Format 3-4 Orang)',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    children: anggota.map((id) {
                      final p = _getPraktikanById(id);
                      if (p == null) return const SizedBox();

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFFF1F5F9),
                              child: Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['nama'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'NIM: ${p['nim']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // =========================
            // DAFTAR PRAKTIKAN
            // =========================
            if (selectedMataPraktikumId != null) ...[
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Daftar Praktikan Terdaftar (${praktikan.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (praktikan.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text(
                      'Belum ada praktikan terdaftar di mata praktikum ini.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                ...praktikan.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  final klp = p['kelompok']?.toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      title: Text(
                        p['nama'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        'NIM: ${p['nim']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: klp != null
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          klp ?? 'Belum ada',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: klp != null
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}