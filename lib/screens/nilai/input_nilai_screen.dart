import 'package:flutter/material.dart';
import 'package:lab_mate/database/database_helper.dart';
import 'package:lab_mate/utils/komputasi_helper.dart';

class NilaiInputScreen extends StatefulWidget {
  const NilaiInputScreen({Key? key}) : super(key: key);

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

      print('DATA MATA PRAKTIKUM: $data');

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
            'Nilai berhasil disimpan. '
            'Nilai Akhir: $hasilBulat',
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Nilai'), elevation: 0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =========================
                  // MATA PRAKTIKUM
                  // =========================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mata Praktikum',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            isExpanded: true,
                            hint: const Text('Pilih Mata Praktikum'),
                            value: selectedMataPraktikumId,
                            items: mataPraktikumList.map((mp) {
                              return DropdownMenuItem<int>(
                                value: mp['id'] as int,
                                child: Text(mp['nama'].toString()),
                              );
                            }).toList(),
                            onChanged: _handleMataPraktikumChanged,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // PRAKTIKAN
                  // =========================
                  if (selectedMataPraktikumId != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Praktikan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<int>(
                              isExpanded: true,
                              hint: const Text('Pilih Praktikan'),
                              value: selectedPraktikanId,
                              items: praktikanList.map((p) {
                                return DropdownMenuItem<int>(
                                  value: p['id'] as int,
                                  child: Text('${p['nim']} - ${p['nama']}'),
                                );
                              }).toList(),
                              onChanged: _handlePraktikanChanged,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // =========================
                  // INPUT NILAI
                  // =========================
                  if (selectedPraktikanId != null &&
                      komponenBobotList.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Input Skor (0-100)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ...List.generate(komponenBobotList.length, (index) {
                              final komponen = komponenBobotList[index];

                              final id = komponen['id'] as int;

                              final bobot =
                                  (komponen['bobot'] as num?)?.toDouble() ??
                                  0.0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${komponen['nama_komponen']} '
                                      '(${bobot.toStringAsFixed(0)}%)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: skorControllers[id],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        hintText: 'Masukkan skor',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // =========================
                  // NILAI AKHIR
                  // =========================
                  if (nilaiAkhir != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Nilai Akhir',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nilaiAkhir!.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Grade: ${KomputasiHelper.tentukanGrade(nilaiAkhir!)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // =========================
                  // TOMBOL SIMPAN
                  // =========================
                  if (selectedPraktikanId != null &&
                      komponenBobotList.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _simpanNilai,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Nilai'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                  // =========================
                  // NILAI TERSIMPAN
                  // =========================
                  if (selectedPraktikanId != null &&
                      nilaiExistingList.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nilai Tersimpan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                ...nilaiExistingList.map((nilai) {
                                  final skor =
                                      (nilai['skor'] as num?)?.toDouble() ??
                                      0.0;

                                  final bobot =
                                      (nilai['bobot'] as num?)?.toDouble() ??
                                      0.0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${nilai['nama_komponen']} '
                                            '(${bobot.toStringAsFixed(0)}%)',
                                          ),
                                        ),
                                        Text(
                                          skor.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
