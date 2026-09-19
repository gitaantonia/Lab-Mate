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

    final data = await dbHelper.getPraktikanByMataPraktikum(mataPraktikumId);

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Rekap Nilai Praktikan'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =========================
            // FILTER MATA PRAKTIKUM
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
                    hint: const Text('Pilih mata praktikum untuk melihat rekap'),
                    items: mataPraktikum.map((mata) {
                      return DropdownMenuItem<int>(
                        value: mata['id'] as int,
                        child: Text(
                          mata['nama'].toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // KONTEN REKAPITULASI
            // =========================
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (selectedMataPraktikumId == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.table_chart_outlined,
                          size: 48,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pilih Mata Praktikum',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Silakan pilih mata praktikum terlebih dahulu untuk menampilkan rekap.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (praktikan.isEmpty)
              Expanded(
                child: Center(
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
                          Icons.people_outline_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Data Praktikan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Belum ada mahasiswa yang terdaftar pada mata praktikum ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: const Color(0xFFF8FAFC),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Mahasiswa: ${praktikan.length}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const Text(
                              'Geser tabel untuk melihat rincian →',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                const Color(0xFFF1F5F9),
                              ),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                fontSize: 13,
                              ),
                              columnSpacing: 22,
                              horizontalMargin: 16,
                              columns: const [
                                DataColumn(label: Text('No')),
                                DataColumn(label: Text('NIM')),
                                DataColumn(label: Text('Nama Praktikan')),
                                DataColumn(label: Text('Nilai Akhir'), numeric: true),
                                DataColumn(label: Text('Grade')),
                                DataColumn(label: Text('Aksi')),
                              ],
                              rows: praktikan.asMap().entries.map((entry) {
                                final index = entry.key;
                                final data = entry.value;
                                final nilaiAkhir =
                                    (data['nilai_akhir'] as num?)?.toDouble() ?? 0.0;
                                final grade = _getGrade(nilaiAkhir);
                                final gradeColor = _getGradeColor(grade);

                                return DataRow(
                                  cells: [
                                    DataCell(Text('${index + 1}')),
                                    DataCell(
                                      Text(
                                        data['nim'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        data['nama'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        nilaiAkhir.toStringAsFixed(2),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: gradeColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          grade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            color: gradeColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      OutlinedButton.icon(
                                        onPressed: () => _lihatDetail(data),
                                        icon: const Icon(Icons.visibility_outlined, size: 15),
                                        label: const Text('Detail'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    final gradeColor = _getGradeColor(grade);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Rincian Nilai Praktikan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PROFIL PRAKTIKAN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NIM: $nim',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // NILAI AKHIR HERO BANNER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                    'Nilai Akhir Terakumulasi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nilaiAkhir.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: gradeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Grade: $grade',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Rincian Komponen Nilai',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 10),

            if (nilai.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    'Belum ada rincian komponen nilai yang diinputkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF1F5F9),
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text('Komponen'),
                      ),
                      DataColumn(
                        label: Text('Skor'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Bobot'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Nilai Terbobot'),
                        numeric: true,
                      ),
                    ],
                    rows: [
                      ...nilai.map((item) {
                        final namaKomponen =
                            item['nama_komponen']?.toString() ?? '-';
                        final skor = (item['skor'] as num?)?.toDouble() ?? 0.0;
                        final bobot = (item['bobot'] as num?)?.toDouble() ?? 0.0;
                        final nilaiTerbobot = skor * bobot / 100;

                        return DataRow(
                          cells: [
                            DataCell(Text(namaKomponen)),
                            DataCell(Text(skor.toStringAsFixed(1))),
                            DataCell(Text('${bobot.toStringAsFixed(0)}%')),
                            DataCell(
                              Text(
                                nilaiTerbobot.toStringAsFixed(2),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        );
                      }),
                      DataRow(
                        color: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        cells: [
                          const DataCell(
                            Text(
                              'TOTAL',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const DataCell(Text('-')),
                          DataCell(
                            Text(
                              '${nilai.fold<double>(
                                0.0,
                                (total, item) =>
                                    total +
                                    ((item['bobot'] as num?)?.toDouble() ?? 0.0),
                              ).toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          DataCell(
                            Text(
                              nilaiAkhir.toStringAsFixed(2),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
