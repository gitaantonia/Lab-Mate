import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// [AKSES DATABASE - READ ONLY / UPDATE TANGGAL LAHIR] Impor DBHelper untuk mengelola tanggal lahir praktikan di SQLite
import '../database/database_helper.dart';
import '../utils/kalender_helper.dart';
import '../utils/session_helper.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  SessionData? session;
  String? tanggalLahirStr;
  DateTime? tanggalLahirDate;
  TimeOfDay? jamLahirTime;
  bool tahuJamLahir = false;

  Map<String, dynamic>? hasilUmur;
  Map<String, String>? hasilWeton;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    setState(() => isLoading = true);
    final data = await SessionHelper.ambil();
    final prefs = await SharedPreferences.getInstance();

    String tglLahir = '2001-01-01'; // Default acuan
    bool hasJam = prefs.getBool('tahu_jam_${data?.username}') ?? false;
    int jamSaved = prefs.getInt('jam_lahir_${data?.username}') ?? 0;
    int menitSaved = prefs.getInt('menit_lahir_${data?.username}') ?? 0;

    // Cek penyimpanan kustom per akun di SharedPreferences
    final prefKey = 'tgl_lahir_${data?.username}';
    final savedPref = prefs.getString(prefKey);

    if (savedPref != null && savedPref.isNotEmpty) {
      tglLahir = savedPref;
    } else if (data?.praktikanId != null) {
      // [AKSES DATABASE - READ ONLY] Mengambil tanggal lahir praktikan tersimpan dari SQLite
      try {
        final listP = await DBHelper.instance.getPraktikan();
        final p = listP.firstWhere(
          (item) => item['id'] == data!.praktikanId,
          orElse: () => {},
        );
        if (p.isNotEmpty && p['tanggal_lahir'] != null) {
          tglLahir = p['tanggal_lahir'].toString();
        }
      } catch (e) {
        debugPrint('Gagal membaca tanggal lahir DB: $e');
      }
    }

    DateTime? parsedDate;
    try {
      final parts = tglLahir.split('-');
      if (parts.length >= 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2].split(' ')[0]);
        parsedDate = DateTime(y, m, d, hasJam ? jamSaved : 0, hasJam ? menitSaved : 0);
      }
    } catch (_) {
      parsedDate = DateTime(2001, 1, 1, 0, 0);
    }

    if (mounted) {
      setState(() {
        session = data;
        tanggalLahirStr = tglLahir;
        tanggalLahirDate = parsedDate;
        tahuJamLahir = hasJam;
        if (hasJam) {
          jamLahirTime = TimeOfDay(hour: jamSaved, minute: menitSaved);
        }
        if (parsedDate != null) {
          hasilUmur = hitungUmur(parsedDate);
          hasilWeton = hitungWeton(parsedDate);
        }
        isLoading = false;
      });
    }
  }

  Future<void> _ubahTanggalLahir(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: tanggalLahirDate ?? DateTime(2001, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'PILIH TANGGAL LAHIR SAYA',
    );

    if (pickedDate == null) return;

    // Tanya apakah tahu jam lahir
    final bool? inginInputJam = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue),
            SizedBox(width: 8),
            Text('Jam Lahir'),
          ],
        ),
        content: const Text('Apakah Anda mengetahui jam lahir Anda secara spesifik?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak (Pukul 00:00)'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Input Jam'),
          ),
        ],
      ),
    );

    TimeOfDay chosenTime = const TimeOfDay(hour: 0, minute: 0);
    bool userKnowsTime = inginInputJam ?? false;

    if (userKnowsTime && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: jamLahirTime ?? const TimeOfDay(hour: 8, minute: 0),
        helpText: 'PILIH JAM LAHIR SAYA',
      );
      if (pickedTime != null) {
        chosenTime = pickedTime;
      } else {
        userKnowsTime = false;
      }
    }

    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      userKnowsTime ? chosenTime.hour : 0,
      userKnowsTime ? chosenTime.minute : 0,
    );

    final newTglStr =
        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tgl_lahir_${session?.username}', newTglStr);
    await prefs.setBool('tahu_jam_${session?.username}', userKnowsTime);
    if (userKnowsTime) {
      await prefs.setInt('jam_lahir_${session?.username}', chosenTime.hour);
      await prefs.setInt('menit_lahir_${session?.username}', chosenTime.minute);
    } else {
      await prefs.remove('jam_lahir_${session?.username}');
      await prefs.remove('menit_lahir_${session?.username}');
    }

    if (session?.praktikanId != null) {
      // [AKSES DATABASE - UPDATE TANGGAL LAHIR EXISTINGS] Meng-update data tanggal lahir praktikan yang bersangkutan
      try {
        final listP = await DBHelper.instance.getPraktikan();
        final p = listP.firstWhere((item) => item['id'] == session!.praktikanId, orElse: () => {});
        if (p.isNotEmpty) {
          await DBHelper.instance.updatePraktikan(
            id: session!.praktikanId!,
            mataPraktikumId: p['mata_praktikum_id'] as int? ?? 1,
            nim: p['nim'] as String? ?? session!.username,
            nama: p['nama'] as String? ?? session!.nama,
            tanggalLahir: newTglStr,
          );
        }
      } catch (e) {
        debugPrint('Gagal update tanggal lahir praktikan di DB: $e');
      }
    }

    if (mounted) {
      setState(() {
        tanggalLahirStr = newTglStr;
        tanggalLahirDate = combinedDateTime;
        tahuJamLahir = userKnowsTime;
        jamLahirTime = userKnowsTime ? chosenTime : null;
        hasilUmur = hitungUmur(combinedDateTime);
        hasilWeton = hitungWeton(combinedDateTime);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userKnowsTime
                ? 'Tanggal & Jam Lahir diperbarui: $newTglStr (${chosenTime.format(context)})'
                : 'Tanggal Lahir diperbarui: $newTglStr (Default 00:00)',
          ),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SessionHelper.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bd = hasilUmur?['breakdown'];
    final nama = session?.nama ?? 'Pengguna';
    final role = session?.role == 'aslab' ? 'Asisten Laboratorium' : 'Praktikan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Avatar Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nama,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: session?.role == 'aslab' ? Colors.blue.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: session?.role == 'aslab' ? Colors.blue.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card Profil & Detail Umur Otomatis
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.cake, color: Colors.pinkAccent),
                                  SizedBox(width: 8),
                                  Text(
                                    'Kalkulator Umur Diri Sendiri',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_calendar, color: Colors.blue),
                                tooltip: 'Ubah Tanggal / Jam Lahir',
                                onPressed: () => _ubahTanggalLahir(context),
                              ),
                            ],
                          ),
                          const Divider(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tanggal Lahir', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                              Row(
                                children: [
                                  Text(tanggalLahirStr ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _ubahTanggalLahir(context),
                                    child: const Text('(Ubah)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Jam Lahir Spesifik', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                              Text(
                                tahuJamLahir && jamLahirTime != null
                                    ? jamLahirTime!.format(context)
                                    : 'Tidak Ada (00:00)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: tahuJamLahir ? Colors.blue.shade700 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (hasilWeton != null) ...[
                            _infoRow('Weton Lahir', hasilWeton!['weton'] ?? '-'),
                            const SizedBox(height: 10),
                          ],

                          if (bd != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.pink.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Usia Otomatis Terhitung:',
                                    style: TextStyle(fontSize: 12, color: Colors.pink, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${bd['tahun']} Tahun, ${bd['bulan']} Bulan, ${bd['hari']} Hari',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Presisi: ${bd['jam']} jam ${bd['menit']} m ${bd['detik']} d',
                                    style: TextStyle(fontSize: 12, color: Colors.pink.shade700, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar dari Akun'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
