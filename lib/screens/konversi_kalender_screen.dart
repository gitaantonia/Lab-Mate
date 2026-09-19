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
      firstDate: DateTime(1500),
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
      backgroundColor: const Color(0xFFF8FAFC),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF1E40AF)),
                        SizedBox(width: 8),
                        Text(
                          'Pilih Tanggal Masehi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_note_rounded, size: 20, color: Color(0xFF64748B)),
                                const SizedBox(width: 10),
                                Text(
                                  '${selectedDate.day.toString().padLeft(2, '0')} / '
                                  '${selectedDate.month.toString().padLeft(2, '0')} / '
                                  '${selectedDate.year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _pilihTanggal(context),
                          icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                          label: const Text('Ubah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E40AF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                subtitle: 'Algoritma Tabular Hijriah Standar',
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF0D9488),
                badgeColor: const Color(0xFFF0FDFA),
                borderColor: const Color(0xFF99F6E4),
                content: '${dataHijriah!['tanggal']} ${dataHijriah!['namaBulan']} ${dataHijriah!['tahun']} H',
              ),

            const SizedBox(height: 12),

            // Card 2: Weton Jawa
            if (dataWeton != null)
              _buildResultCard(
                title: 'Weton Jawa',
                subtitle: 'Siklus Pasaran (Legi, Pahing, Pon, Wage, Kliwon)',
                icon: Icons.wb_twilight_rounded,
                iconColor: const Color(0xFFD97706),
                badgeColor: const Color(0xFFFFFBEB),
                borderColor: const Color(0xFFFDE68A),
                content: '${dataWeton!['weton']}',
              ),

            const SizedBox(height: 12),

            // Card 3: Wuku / Pawukon (Pendekatan Saka Bali)
            if (dataWuku != null)
              _buildResultCard(
                title: 'Wuku / Pawukon (Bali)',
                subtitle: 'Siklus 210 Hari Pawukon',
                icon: Icons.spa_rounded,
                iconColor: const Color(0xFFEA580C),
                badgeColor: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFFED7AA),
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
    required Color badgeColor,
    required Color borderColor,
    required String content,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Terkonversi',
                          style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
                    ),
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
