import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../utils/komputasi_helper.dart';

class RekapNilaiScreen extends StatefulWidget {
  const RekapNilaiScreen({super.key});

  @override
  State<RekapNilaiScreen> createState() => _RekapNilaiScreenState();
}

class _RekapNilaiScreenState extends State<RekapNilaiScreen> {
  final DBHelper dbHelper = DBHelper.instance;

  List<Map<String, dynamic>> mataPraktikum = [];
  List<Map<String, dynamic>> praktikan = [];

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

  Future<void> _loadRekap(int mataPraktikumId) async {
    setState(() {
      isLoading = true;
      praktikan = [];
    });

    final data =
        await dbHelper.getPraktikanByMataPraktikum(mataPraktikumId);

    if (!mounted) return;

    setState(() {
      praktikan = data;
      isLoading = false;
    });
  }

  String _getGrade(double nilai) {
    if (nilai >= 85) return 'A';
    if (nilai >= 75) return 'B';
    if (nilai >= 65) return 'C';
    if (nilai >= 55) return 'D';
    return 'E';
  }

  Future<void> _lihatDetail(Map<String, dynamic> data) async {
    final praktikanId = data['id'] as int;

    final nilai = await dbHelper.getNilaiPraktikan(praktikanId);

    if (!mounted) return;

    final nilaiAkhir = nilai.isEmpty
        ? 0.0
        : KomputasiHelper.hitungNilaiAkhir(
            nilaiKomponen: nilai,
          );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailNilaiScreen(
          nama: data['nama'].toString(),
          nim: data['nim'].toString(),
          nilai: nilai,
          nilaiAkhir: nilaiAkhir,
          grade: _getGrade(nilaiAkhir),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Nilai'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedMataPraktikumId,
              decoration: const InputDecoration(
                labelText: 'Pilih Mata Praktikum',
                border: OutlineInputBorder(),
              ),
              items: mataPraktikum.map((mata) {
                return DropdownMenuItem<int>(
                  value: mata['id'] as int,
                  child: Text(mata['nama'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedMataPraktikumId = value;
                });

                _loadRekap(value);
              },
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (selectedMataPraktikumId == null)
              const Expanded(
                child: Center(
                  child: Text(
                    'Silakan pilih mata praktikum terlebih dahulu.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (praktikan.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Belum ada data praktikan.',
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('NIM')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Nilai Akhir')),
                      DataColumn(label: Text('Grade')),
                      DataColumn(label: Text('Detail')),
                    ],
                    rows: praktikan.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;

                      final nilaiAkhir =
                          (data['nilai_akhir'] as num?)?.toDouble() ?? 0.0;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text('${index + 1}'),
                          ),
                          DataCell(
                            Text(data['nim'].toString()),
                          ),
                          DataCell(
                            Text(data['nama'].toString()),
                          ),
                          DataCell(
                            Text(nilaiAkhir.toStringAsFixed(2)),
                          ),
                          DataCell(
                            Text(_getGrade(nilaiAkhir)),
                          ),
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () => _lihatDetail(data),
                              icon: const Icon(
                                Icons.visibility,
                                size: 18,
                              ),
                              label: const Text('Lihat'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HALAMAN DETAIL NILAI
// ============================================================

class DetailNilaiScreen extends StatelessWidget {
  final String nama;
  final String nim;
  final List<Map<String, dynamic>> nilai;
  final double nilaiAkhir;
  final String grade;

  const DetailNilaiScreen({
    super.key,
    required this.nama,
    required this.nim,
    required this.nilai,
    required this.nilaiAkhir,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Nilai'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PROFIL PRAKTIKAN
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIM: $nim',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // NILAI AKHIR
            Card(
              elevation: 3,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Nilai Akhir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nilaiAkhir.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Grade: $grade',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Rincian Komponen Nilai',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (nilai.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada nilai yang diinputkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor:
                          WidgetStateProperty.all(
                        Colors.blue.shade50,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Komponen',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Skor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(
                            'Bobot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(
                            'Nilai Terbobot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          numeric: true,
                        ),
                      ],
                      rows: [
                        ...nilai.map((item) {
                          final namaKomponen =
                              item['nama_komponen']?.toString() ?? '-';

                          final skor =
                              (item['skor'] as num?)?.toDouble() ?? 0.0;

                          final bobot =
                              (item['bobot'] as num?)?.toDouble() ?? 0.0;

                          final nilaiTerbobot =
                              skor * bobot / 100;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(namaKomponen),
                              ),
                              DataCell(
                                Text(
                                  skor.toStringAsFixed(1),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${bobot.toStringAsFixed(0)}%',
                                ),
                              ),
                              DataCell(
                                Text(
                                  nilaiTerbobot.toStringAsFixed(2),
                                ),
                              ),
                            ],
                          );
                        }),

                        DataRow(
                          cells: [
                            const DataCell(
                              Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const DataCell(
                              Text('-'),
                            ),
                            DataCell(
                              Text(
                                '${nilai.fold<double>(
                                  0.0,
                                  (total, item) =>
                                      total +
                                      ((item['bobot'] as num?)
                                              ?.toDouble() ??
                                          0.0),
                                ).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                nilaiAkhir.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

