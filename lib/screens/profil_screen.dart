import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    // Cek penyimpanan kustom per akun di SharedPreferences
    final prefKey = 'tgl_lahir_${data?.username}';
    final savedPref = prefs.getString(prefKey);

    if (savedPref != null && savedPref.isNotEmpty) {
      tglLahir = savedPref;
    } else if (data?.praktikanId != null) {
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
      if (parts.length == 3) {
        parsedDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (_) {
      parsedDate = DateTime(2001, 1, 1);
    }

    if (mounted) {
      setState(() {
        session = data;
        tanggalLahirStr = tglLahir;
        tanggalLahirDate = parsedDate;
        if (parsedDate != null) {
          hasilUmur = hitungUmur(parsedDate);
          hasilWeton = hitungWeton(parsedDate);
        }
        isLoading = false;
      });
    }
  }

  Future<void> _ubahTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalLahirDate ?? DateTime(2001, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'PILIH TANGGAL LAHIR SAYA',
    );

    if (picked != null) {
      final newTglStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tgl_lahir_${session?.username}', newTglStr);

      if (session?.praktikanId != null) {
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

      if (!mounted) return;

      setState(() {
        tanggalLahirStr = newTglStr;
        tanggalLahirDate = picked;
        hasilUmur = hitungUmur(picked);
        hasilWeton = hitungWeton(picked);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tanggal lahir berhasil diperbarui: $newTglStr'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Konfirmasi Logout', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SessionHelper.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bd = hasilUmur?['breakdown'];
    final nama = session?.nama ?? 'Pengguna';
    final role = session?.role == 'aslab' ? 'Asisten Laboratorium' : 'Mahasiswa Praktikan';
    final isAslab = session?.role == 'aslab';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  // =========================
                  // HEADER PROFILE CARD
                  // =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: isAslab ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                          child: Text(
                            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: isAslab ? const Color(0xFF1E40AF) : const Color(0xFF047857),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          nama,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Username: ${session?.username ?? '-'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAslab ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAslab ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isAslab ? const Color(0xFF1E40AF) : const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // CARD DETAIL UMUR & WETON
                  // =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.cake_rounded, color: Color(0xFFDB2777), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Kalkulator Umur Pribadi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF2563EB), size: 20),
                              tooltip: 'Ubah Tanggal Lahir',
                              onPressed: _ubahTanggalLahir,
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tanggal Lahir',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            Row(
                              children: [
                                Text(
                                  tanggalLahirStr ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: _ubahTanggalLahir,
                                  child: const Text(
                                    '(Ubah)',
                                    style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (hasilWeton != null) ...[
                          _infoRow('Weton Kelahiran Jawa', hasilWeton!['weton'] ?? '-'),
                          const SizedBox(height: 12),
                        ],

                        if (bd != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF2F8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFBCFE8)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Usia Otomatis Terhitung:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFDB2777),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${bd['tahun']} Tahun, ${bd['bulan']} Bulan, ${bd['hari']} Hari',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF831843),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Presisi: ${bd['jam']} jam ${bd['menit']} menit ${bd['detik']} detik',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFBE185D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // TOMBOL LOGOUT
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                      label: const Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
      ],
    );
  }
}
