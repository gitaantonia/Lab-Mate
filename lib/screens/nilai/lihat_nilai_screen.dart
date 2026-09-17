import 'package:flutter/material.dart';
// [AKSES DATABASE - READ ONLY] Mengimpor DBHelper hanya untuk membaca data nilai tersimpan
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

      // [AKSES DATABASE - READ ONLY] Mencari data praktikan dan nilainya berdasarkan praktikanId/session
      final db = DBHelper.instance;
      if (praktikanId != null) {
        // [AKSES DATABASE - READ ONLY] Query nilai komponen praktikan yang tersimpan
        final data = await db.getNilaiPraktikan(praktikanId);
        
        // [AKSES DATABASE - READ ONLY] Query data praktikan untuk mengambil nama & nim
        final praktikanList = await db.getPraktikan();
        final currentP = praktikanList.firstWhere(
          (p) => p['id'] == praktikanId,
          orElse: () => {'nama': session?.nama ?? 'Praktikan', 'nim': session?.username ?? '-'},
        );

        double totalNilai = 0.0;
        if (data.isNotEmpty) {
          totalNilai = KomputasiHelper.hitungNilaiAkhir(nilaiKomponen: data);
        }

        if (mounted) {
          setState(() {
            listNilai = data;
            nilaiAkhir = data.isNotEmpty ? KomputasiHelper.bulatkanNilai(totalNilai) : null;
            namaPraktikan = currentP['nama'] as String?;
            nimPraktikan = currentP['nim'] as String?;
          });
        }
      } else {
        // Jika aslab melihat screen ini secara umum atau belum ada sesi praktikan
        setState(() {
          namaPraktikan = session?.nama ?? 'Pengguna';
          nimPraktikan = session?.username ?? '-';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat nilai: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komputasi Nilai Saya'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Profil Ringkas Praktikan
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaPraktikan ?? 'Praktikan',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'NIM: ${nimPraktikan ?? '-'}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Display Nilai Akhir & Grade
                  if (nilaiAkhir != null) ...[
                    Card(
                      elevation: 3,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Nilai Akhir Terakumulasi',
                              style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nilaiAkhir!.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Grade: ${KomputasiHelper.tentukanGrade(nilaiAkhir!)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Detail Rincian Komponen Nilai
                  const Text(
                    'Rincian Komponen Nilai',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  if (listNilai.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey.shade400, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada nilai yang diinputkan oleh Aslab.',
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...listNilai.map((item) {
                      final namaComp = item['nama_komponen'] ?? '-';
                      final bobot = (item['bobot'] as num?)?.toDouble() ?? 0.0;
                      final skor = (item['skor'] as num?)?.toDouble() ?? 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(Icons.assignment_outlined, color: Colors.blue),
                          ),
                          title: Text(namaComp.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Bobot: ${bobot.toStringAsFixed(0)}%'),
                          trailing: Text(
                            skor.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
