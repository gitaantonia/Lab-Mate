import 'package:flutter/material.dart';
import '../utils/kalender_helper.dart';

class KalkulatorUmurScreen extends StatefulWidget {
  const KalkulatorUmurScreen({super.key});

  @override
  State<KalkulatorUmurScreen> createState() => _KalkulatorUmurScreenState();
}

class _KalkulatorUmurScreenState extends State<KalkulatorUmurScreen> {
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 365 * 20));
  TimeOfDay selectedTime = const TimeOfDay(hour: 0, minute: 0);
  bool tahuJamLahir = false;

  Map<String, dynamic>? hasilUmur;

  @override
  void initState() {
    super.initState();
    _hitung();
  }

  void _hitung() {
    final combinedDate = tahuJamLahir
        ? DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          )
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            0,
            0,
            0,
          );

    setState(() {
      hasilUmur = hitungUmur(combinedDate);
    });
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1500),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _hitung();
    }
  }

  Future<void> _pilihJam(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
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
            // Card Input Tanggal & Jam
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                          label: const Text('Ubah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E40AF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Opsi Jam Lahir
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Tahu Jam Lahir?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        tahuJamLahir
                            ? 'Menghitung presisi dari jam ${selectedTime.format(context)}'
                            : 'Default (dianggap pukul 00:00 WIB)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      value: tahuJamLahir,
                      onChanged: (val) {
                        setState(() {
                          tahuJamLahir = val;
                        });
                        _hitung();
                      },
                    ),

                    if (tahuJamLahir) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.blue, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Jam Lahir: ${selectedTime.format(context)}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _pilihJam(context),
                            icon: const Icon(Icons.time_to_leave_outlined),
                            label: const Text('Pilih Jam'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (bd != null && tot != null) ...[
              // Card Hasil Breakdown
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E40AF).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Usia Anda Saat Ini',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${bd['tahun']} Tahun ${bd['bulan']} Bulan ${bd['hari']} Hari',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${bd['jam']} jam, ${bd['menit']} menit, ${bd['detik']} detik',
                      style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
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
