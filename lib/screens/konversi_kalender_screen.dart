import 'package:flutter/material.dart';
import '../utils/kalender_helper.dart';

class KonversiKalenderScreen extends StatefulWidget {
  const KonversiKalenderScreen({super.key});

  @override
  State<KonversiKalenderScreen> createState() => _KonversiKalenderScreenState();
}

class _KonversiKalenderScreenState extends State<KonversiKalenderScreen> {
  DateTime selectedDate = DateTime.now();

  Map<String, dynamic>? dataHijriah;
  Map<String, String>? dataWeton;
  Map<String, dynamic>? dataWuku;

  @override
  void initState() {
    super.initState();
    _konversi();
  }

  void _konversi() {
    setState(() {
      dataHijriah = masehiKeHijriah(selectedDate.day, selectedDate.month, selectedDate.year);
      dataWeton = hitungWeton(selectedDate);
      dataWuku = hitungWuku(selectedDate);
    });
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1800),
      lastDate: DateTime(2200),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _konversi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Kalender'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Select Date Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Tanggal Masehi',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              '${selectedDate.day.toString().padLeft(2, '0')} / '
                              '${selectedDate.month.toString().padLeft(2, '0')} / '
                              '${selectedDate.year}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _pilihTanggal(context),
                          icon: const Icon(Icons.event),
                          label: const Text('Pilih'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card 1: Kalender Hijriah
            if (dataHijriah != null)
              _buildResultCard(
                title: 'Kalender Hijriah',
                subtitle: 'Algoritma Tabular Hijriah',
                icon: Icons.brightness_3,
                iconColor: Colors.teal,
                content: '${dataHijriah!['tanggal']} ${dataHijriah!['namaBulan']} ${dataHijriah!['tahun']} H',
              ),

            const SizedBox(height: 12),

            // Card 2: Weton Jawa
            if (dataWeton != null)
              _buildResultCard(
                title: 'Weton Jawa',
                subtitle: 'Siklus Pasaran (Legi, Pahing, Pon, Wage, Kliwon)',
                icon: Icons.wb_twilight,
                iconColor: Colors.amber.shade800,
                content: '${dataWeton!['weton']}',
              ),

            const SizedBox(height: 12),

            // Card 3: Wuku / Pawukon (Pendekatan Saka Bali)
            if (dataWuku != null)
              _buildResultCard(
                title: 'Wuku / Pawukon (Bali)',
                subtitle: 'Siklus 210 Hari Pawukon',
                icon: Icons.spa,
                iconColor: Colors.deepOrange,
                content: 'Wuku ${dataWuku!['namaWuku']} (Ke-${dataWuku!['nomorWuku']} dari 30)\nHari ke-${dataWuku!['hariKe']} dalam wuku',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.12),
              radius: 24,
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
