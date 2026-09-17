import 'package:flutter/material.dart';
import '../utils/kalender_helper.dart';

class KalkulatorUmurScreen extends StatefulWidget {
  const KalkulatorUmurScreen({super.key});

  @override
  State<KalkulatorUmurScreen> createState() => _KalkulatorUmurScreenState();
}

class _KalkulatorUmurScreenState extends State<KalkulatorUmurScreen> {
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 365 * 20));
  Map<String, dynamic>? hasilUmur;

  @override
  void initState() {
    super.initState();
    _hitung();
  }

  void _hitung() {
    setState(() {
      hasilUmur = hitungUmur(selectedDate);
    });
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _hitung();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bd = hasilUmur?['breakdown'];
    final tot = hasilUmur?['total'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Umur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Input Tanggal
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Tanggal Lahir / Acuan',
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
                          icon: const Icon(Icons.calendar_today),
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

            if (bd != null && tot != null) ...[
              // Card Hasil Breakdown
              Card(
                elevation: 2,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Usia Anda Saat Ini',
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${bd['tahun']} Tahun ${bd['bulan']} Bulan ${bd['hari']} Hari',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bd['jam']} jam, ${bd['menit']} menit, ${bd['detik']} detik',
                        style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Total Statistik',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Grid Total Statistik
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _statItem('Total Hari', '${tot['totalHari']}', Icons.wb_sunny_outlined, Colors.orange),
                  _statItem('Total Jam', '${tot['totalJam']}', Icons.access_time, Colors.blue),
                  _statItem('Total Menit', '${tot['totalMenit']}', Icons.timer_outlined, Colors.green),
                  _statItem('Total Detik', '${tot['totalDetik']}', Icons.speed_outlined, Colors.purple),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
