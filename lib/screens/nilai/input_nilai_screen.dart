import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../utils/komputasi_helper.dart';

class NilaiInputScreen extends StatefulWidget {
  const NilaiInputScreen({super.key});

  @override
  State<NilaiInputScreen> createState() => _NilaiInputScreenState();
}

class _NilaiInputScreenState extends State<NilaiInputScreen> {
  final dbHelper = DBHelper.instance;

  List<Map<String, dynamic>> mataPraktikumList = [];
  List<Map<String, dynamic>> praktikanList = [];
  List<Map<String, dynamic>> komponenBobotList = [];
  List<Map<String, dynamic>> nilaiExistingList = [];

  int? selectedMataPraktikumId;
  int? selectedPraktikanId;

  Map<int, TextEditingController> skorControllers = {};

  bool isLoading = false;
  double? nilaiAkhir;

  @override
  void initState() {
    super.initState();
    _loadMataPraktikum();
  }

  Future<void> _loadMataPraktikum() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await dbHelper.getMataPraktikum();

      if (!mounted) return;

      setState(() {
        mataPraktikumList = data;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil mata praktikum: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPraktikan(int mataPraktikumId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await dbHelper.getPraktikanByMataPraktikum(mataPraktikumId);

      if (!mounted) return;

      setState(() {
        praktikanList = data;
        selectedPraktikanId = null;
        nilaiExistingList = [];
        nilaiAkhir = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data praktikan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadKomponenBobot(int mataPraktikumId) async {
    try {
      final data = await dbHelper.getKomponenBobot(mataPraktikumId);

      // Dispose controller lama sebelum membuat controller baru.
      for (final controller in skorControllers.values) {
        controller.dispose();
      }

      final Map<int, TextEditingController> controllers = {};

      for (final komponen in data) {
        final id = komponen['id'] as int;
        controllers[id] = TextEditingController();
      }

      if (!mounted) return;

      setState(() {
        komponenBobotList = data;
        skorControllers = controllers;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil komponen nilai: $e')),
      );
    }
  }

  Future<void> _loadNilaiExisting(int praktikanId) async {
    try {
      final data = await dbHelper.getNilaiPraktikan(praktikanId);

      if (!mounted) return;

      setState(() {
        nilaiExistingList = data;
      });

      // Isi nilai yang sudah tersimpan ke TextField.
      for (final nilai in data) {
        final skor = (nilai['skor'] as num?)?.toDouble() ?? 0.0;
        final namaKomponen = nilai['nama_komponen'];

        for (final komponen in komponenBobotList) {
          if (komponen['nama_komponen'] == namaKomponen) {
            final id = komponen['id'] as int;
            skorControllers[id]?.text = skor.toString();
          }
        }
      }

      // Hitung nilai akhir dari nilai yang sudah tersimpan.
      if (data.isNotEmpty) {
        final hasil = KomputasiHelper.hitungNilaiAkhir(nilaiKomponen: data);

        if (mounted) {
          setState(() {
            nilaiAkhir = KomputasiHelper.bulatkanNilai(hasil);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil nilai: $e')));
    }
  }

  void _handleMataPraktikumChanged(int? value) {
    if (value == null) return;

    setState(() {
      selectedMataPraktikumId = value;
      selectedPraktikanId = null;

      komponenBobotList = [];
      nilaiExistingList = [];
      nilaiAkhir = null;
    });

    _loadPraktikan(value);
    _loadKomponenBobot(value);
  }

  void _handlePraktikanChanged(int? value) {
    if (value == null) return;

    setState(() {
      selectedPraktikanId = value;
      nilaiAkhir = null;
    });

    _loadNilaiExisting(value);
  }

  Future<void> _simpanNilai() async {
    if (selectedMataPraktikumId == null) {
      _showMessage('Pilih mata praktikum terlebih dahulu');
      return;
    }

    if (selectedPraktikanId == null) {
      _showMessage('Pilih praktikan terlebih dahulu');
      return;
    }

    if (komponenBobotList.isEmpty) {
      _showMessage('Belum ada komponen nilai');
      return;
    }

    // Validasi total bobot.
    final bobotValid = KomputasiHelper.validasiTotalBobot(
      komponenBobot: komponenBobotList,
    );

    if (!bobotValid) {
      _showMessage('Total bobot harus 100%');
      return;
    }

    final List<double> skorList = [];

    // Validasi semua skor.
    for (final komponen in komponenBobotList) {
      final id = komponen['id'] as int;
      final skorText = skorControllers[id]?.text.trim() ?? '';

      if (skorText.isEmpty) {
        _showMessage('Skor ${komponen['nama_komponen']} tidak boleh kosong');
        return;
      }

      final skor = double.tryParse(skorText);

      if (skor == null) {
        _showMessage('Skor ${komponen['nama_komponen']} tidak valid');
        return;
      }

      if (!KomputasiHelper.validasiSkor(skor)) {
        _showMessage('Skor ${komponen['nama_komponen']} harus antara 0-100');
        return;
      }

      skorList.add(skor);
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Menyimpan setiap komponen nilai.
      for (int i = 0; i < komponenBobotList.length; i++) {
        final komponen = komponenBobotList[i];

        await dbHelper.simpanNilai(
          praktikanId: selectedPraktikanId!,
          komponenBobotId: komponen['id'] as int,
          skor: skorList[i],
        );
      }

      // Mengambil kembali nilai dari database.
      final nilaiData = await dbHelper.getNilaiPraktikan(selectedPraktikanId!);

      // Menghitung nilai akhir.
      final hasilNilaiAkhir = KomputasiHelper.hitungNilaiAkhir(
        nilaiKomponen: nilaiData,
      );

      final hasilBulat = KomputasiHelper.bulatkanNilai(hasilNilaiAkhir);

      // Menyimpan nilai akhir ke database.
      await dbHelper.updateNilaiAkhir(
        praktikanId: selectedPraktikanId!,
        nilaiAkhir: hasilBulat,
      );

      if (!mounted) return;

      setState(() {
        nilaiExistingList = nilaiData;
        nilaiAkhir = hasilBulat;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nilai berhasil disimpan. Nilai Akhir: $hasilBulat',
          ),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan nilai: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    for (final controller in skorControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFF059669);
      case 'B':
        return const Color(0xFF2563EB);
      case 'C':
        return const Color(0xFFD97706);
      case 'D':
      case 'E':
      default:
        return const Color(0xFFE11D48);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Komputasi & Input Nilai'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =========================
                  // CARD 1: MATA PRAKTIKUM
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
                        const Row(
                          children: [
                            Icon(Icons.auto_stories_rounded, color: Color(0xFF2563EB), size: 18),
                            SizedBox(width: 8),
                            Text(
                              '1. Pilih Mata Praktikum',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: selectedMataPraktikumId,
                          isExpanded: true,
                          hint: const Text('Pilih Mata Praktikum'),
                          items: mataPraktikumList.map((mp) {
                            return DropdownMenuItem<int>(
                              value: mp['id'] as int,
                              child: Text(mp['nama'].toString(), overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: _handleMataPraktikumChanged,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // CARD 2: PRAKTIKAN
                  // =========================
                  if (selectedMataPraktikumId != null) ...[
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
                          const Row(
                            children: [
                              Icon(Icons.person_outline_rounded, color: Color(0xFF2563EB), size: 18),
                              SizedBox(width: 8),
                              Text(
                                '2. Pilih Praktikan',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          praktikanList.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Belum ada praktikan terdaftar di mata praktikum ini.',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                )
                              : DropdownButtonFormField<int>(
                                  initialValue: selectedPraktikanId,
                                  isExpanded: true,
                                  hint: const Text('Pilih Nama Mahasiswa'),
                                  items: praktikanList.map((p) {
                                    return DropdownMenuItem<int>(
                                      value: p['id'] as int,
                                      child: Text(
                                        '${p['nim']} - ${p['nama']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _handlePraktikanChanged,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // =========================
                  // CARD 3: INPUT SKOR
                  // =========================
                  if (selectedPraktikanId != null && komponenBobotList.isNotEmpty) ...[
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.edit_note_rounded, color: Color(0xFF7C3AED), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    '3. Input Skor Komponen (0 - 100)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(komponenBobotList.length, (index) {
                            final komponen = komponenBobotList[index];
                            final id = komponen['id'] as int;
                            final bobot = (komponen['bobot'] as num?)?.toDouble() ?? 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          komponen['nama_komponen'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Bobot: ${bobot.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: skorControllers[id],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText: '0 - 100',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // =========================
                    // TOMBOL SIMPAN
                    // =========================
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _simpanNilai,
                        icon: const Icon(Icons.save_rounded, size: 20),
                        label: const Text('Simpan Nilai Praktikan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // =========================
                  // CARD 4: NILAI AKHIR & GRADE
                  // =========================
                  if (nilaiAkhir != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Nilai Akhir Terhitung',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nilaiAkhir!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Builder(builder: (context) {
                            final grade = KomputasiHelper.tentukanGrade(nilaiAkhir!);
                            final color = _getGradeColor(grade);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Grade $grade',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // =========================
                  // CARD 5: NILAI TERSIMPAN
                  // =========================
                  if (selectedPraktikanId != null && nilaiExistingList.isNotEmpty) ...[
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
                          const Row(
                            children: [
                              Icon(Icons.history_rounded, color: Color(0xFF059669), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Nilai Tersimpan di Database',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...nilaiExistingList.map((nilai) {
                            final skor = (nilai['skor'] as num?)?.toDouble() ?? 0.0;
                            final bobot = (nilai['bobot'] as num?)?.toDouble() ?? 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${nilai['nama_komponen']} (${bobot.toStringAsFixed(0)}%)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  Text(
                                    skor.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
