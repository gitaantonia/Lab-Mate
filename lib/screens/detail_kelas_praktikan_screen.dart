import 'package:flutter/material.dart';
// [AKSES DATABASE - READ ONLY] Impor DBHelper untuk membaca anggota kelas spesifik mata praktikum
import '../database/database_helper.dart';

class DetailKelasPraktikanScreen extends StatefulWidget {
  final int mataPraktikumId;
  final String namaMataPraktikum;
  final String namaAslab;
  final String jadwal;

  const DetailKelasPraktikanScreen({
    super.key,
    required this.mataPraktikumId,
    required this.namaMataPraktikum,
    this.namaAslab = 'Tim Aslab Pemrograman',
    this.jadwal = 'Senin, 08:00 - 10:30 WIB',
  });

  @override
  State<DetailKelasPraktikanScreen> createState() => _DetailKelasPraktikanScreenState();
}

class _DetailKelasPraktikanScreenState extends State<DetailKelasPraktikanScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> listAnggota = [];

  @override
  void initState() {
    super.initState();
    _loadAnggotaKelas();
  }

  Future<void> _loadAnggotaKelas() async {
    setState(() => isLoading = true);
    try {
      // [AKSES DATABASE - READ ONLY] Mengambil daftar praktikan yang terdaftar spesifik di mata praktikum ini
      final data = await DBHelper.instance.getPraktikanByMataPraktikum(widget.mataPraktikumId);
      if (mounted) {
        setState(() {
          listAnggota = data;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat anggota kelas: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaMataPraktikum),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Header Kelas (Nama Kelas, Aslab, Jam/Jadwal)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade800, Colors.indigo.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Kelas Praktikum Active',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(Icons.school, color: Colors.white70),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.namaMataPraktikum,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Divider(color: Colors.white30, height: 20),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Aslab: ${widget.namaAslab}',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Jadwal: ${widget.jadwal}',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header Anggota
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Praktikan di Kelas Ini',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${listAnggota.length} Mahasiswa',
                          style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (listAnggota.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada praktikan terdaftar di kelas ini.',
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...listAnggota.map((item) {
                      final nama = item['nama']?.toString() ?? '-';
                      final nim = item['nim']?.toString() ?? '-';
                      final kelompok = item['kelompok']?.toString() ?? '-';
                      final rawTgl = item['tanggal_lahir']?.toString();
                      final tgl = (rawTgl == null || rawTgl.isEmpty || rawTgl == '0000-00-00')
                          ? 'Belum di-set'
                          : rawTgl;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                            ),
                          ),
                          title: Text(
                            nama,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text('NIM: $nim  |  Kelompok: $kelompok\nTgl Lahir: $tgl'),
                          isThreeLine: true,
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
