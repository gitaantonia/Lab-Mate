import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../utils/komputasi_helper.dart';
import '../../utils/session_helper.dart';

class LihatNilaiScreen extends StatefulWidget {
  const LihatNilaiScreen({super.key});

  @override
  State<LihatNilaiScreen> createState() => _LihatNilaiScreenState();
}

class _LihatNilaiScreenState extends State<LihatNilaiScreen> {
  bool isLoading = true;

  List<Map<String, dynamic>> listNilai = [];
  double? nilaiAkhir;

  String? namaPraktikan;
  String? nimPraktikan;

  @override
  void initState() {
    super.initState();
    _loadNilaiPraktikan();
  }

  Future<void> _loadNilaiPraktikan() async {
    setState(() => isLoading = true);

    try {
      final session = await SessionHelper.ambil();
      final praktikanId = session?.praktikanId;

      final db = DBHelper.instance;

      if (praktikanId != null) {
        // Mengambil nilai komponen praktikan
        final data = await db.getNilaiPraktikan(praktikanId);

        // Mengambil data praktikan untuk nama dan NIM
        final praktikanList = await db.getPraktikan();

        final currentP = praktikanList.firstWhere(
          (p) => p['id'] == praktikanId,
          orElse: () => {
            'nama': session?.nama ?? 'Praktikan',
            'nim': session?.username ?? '-',
          },
        );

        double totalNilai = 0.0;

        if (data.isNotEmpty) {
          totalNilai = KomputasiHelper.hitungNilaiAkhir(
            nilaiKomponen: data,
          );
        }

        if (mounted) {
          setState(() {
            listNilai = data;

            nilaiAkhir = data.isNotEmpty
                ? KomputasiHelper.bulatkanNilai(totalNilai)
                : null;

            namaPraktikan = currentP['nama'] as String?;
            nimPraktikan = currentP['nim'] as String?;
          });
        }
      } else {
        // Jika belum ada sesi praktikan
        if (mounted) {
          setState(() {
            namaPraktikan = session?.nama ?? 'Pengguna';
            nimPraktikan = session?.username ?? '-';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat nilai: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
        title: const Text('Komputasi Nilai Saya'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =========================
                  // CARD PROFIL PRAKTIKAN
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(16.0),
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
                            (namaPraktikan != null && namaPraktikan!.isNotEmpty)
                                ? namaPraktikan![0].toUpperCase()
                                : '?',
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
                                namaPraktikan ?? 'Praktikan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'NIM: ${nimPraktikan ?? '-'}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // NILAI AKHIR & GRADE
                  // =========================
                  if (nilaiAkhir != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ),
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
                              color: Color(0xFF1E40AF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nilaiAkhir!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 42,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 6,
                              ),
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

                    const SizedBox(height: 20),
                  ],

                  // =========================
                  // RINCIAN KOMPONEN NILAI
                  // =========================
                  const Text(
                    'Rincian Komponen Nilai',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (listNilai.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              color: Color(0xFF2563EB),
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Belum Ada Nilai',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nilai Anda belum diinputkan oleh Asisten Laboratorium.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
                            // Baris setiap komponen
                            ...listNilai.map(
                              (item) {
                                final namaComp =
                                    item['nama_komponen']?.toString() ?? '-';
                                final bobot =
                                    (item['bobot'] as num?)?.toDouble() ?? 0.0;
                                final skor =
                                    (item['skor'] as num?)?.toDouble() ?? 0.0;
                                final nilaiTerbobot = skor * bobot / 100;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(namaComp)),
                                    DataCell(Text(skor.toStringAsFixed(1))),
                                    DataCell(Text('${bobot.toStringAsFixed(0)}%')),
                                    DataCell(
                                      Text(
                                        nilaiTerbobot.toStringAsFixed(2),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            // Baris TOTAL
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
                                    '${listNilai.fold<double>(
                                      0.0,
                                      (total, item) =>
                                          total +
                                          ((item['bobot'] as num?)
                                                  ?.toDouble() ??
                                              0.0),
                                    ).toStringAsFixed(0)}%',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    listNilai
                                        .fold<double>(
                                          0.0,
                                          (total, item) {
                                            final skor = (item['skor'] as num?)
                                                    ?.toDouble() ??
                                                0.0;
                                            final bobot = (item['bobot'] as num?)
                                                    ?.toDouble() ??
                                                0.0;
                                            return total + (skor * bobot / 100);
                                          },
                                        )
                                        .toStringAsFixed(2),
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
