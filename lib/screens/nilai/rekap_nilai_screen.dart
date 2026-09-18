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

  Future<double> _hitungNilaiAkhir(int praktikanId) async {
    final data = await dbHelper.getNilaiPraktikan(praktikanId);

    if (data.isEmpty) {
      return 0.0;
    }

    return KomputasiHelper.hitungNilaiAkhir(
      nilaiKomponen: data,
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
              value: selectedMataPraktikumId,
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