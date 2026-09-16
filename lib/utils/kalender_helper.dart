import 'dart:io';

// =====================================================
// KONVERSI TANGGAL — LabMate (versi CLI, logic murni)
// Mencakup 2 layar sesuai rencana:
//   1. "Konversi Tanggal Lahir"  -> Hijriah + Umur
//   2. "Konversi Kalender Budaya" -> Weton (Jawa) + Wuku (Pawukon,
//      dipakai sebagai pendekatan Saka Bali — BUKAN Saka penuh,
//      lihat catatan di bagian hitungWuku()).
//
// SEMUA fungsi di sini "bersih" (tanpa print/stdin) supaya nanti
// tinggal dipanggil persis sama dari layar Flutter, seperti pola
// test_login_logic.dart sebelumnya.
// =====================================================

// ================= VALIDASI (batasan) =================
// Ditaruh paling atas & dipanggil di semua fungsi konversi,
// karena ini exact jenis validasi yang sebelumnya bikin nilai
// kalkulator kamu dikurangi (nggak bisa pakai koma).
String? validasiTanggal(int tanggal, int bulan, int tahun) {
  if (bulan < 1 || bulan > 12) return 'Bulan harus 1-12.';
  if (tahun < 1900 || tahun > DateTime.now().year) {
    return 'Tahun harus antara 1900 dan tahun sekarang.';
  }
  int hariDalamBulan = DateTime(tahun, bulan + 1, 0).day;
  if (tanggal < 1 || tanggal > hariDalamBulan) {
    return 'Tanggal $tanggal tidak valid untuk bulan $bulan/$tahun (maks $hariDalamBulan).';
  }
  DateTime hasil = DateTime(tahun, bulan, tanggal);
  if (hasil.isAfter(DateTime.now())) {
    return 'Tanggal tidak boleh di masa depan.';
  }
  return null; // null = valid
}

// ================= 1. KONVERSI UMUR =================
// Return dua representasi sekaligus, karena instruksi tugas ambigu
// antara "breakdown bertingkat" vs "total per satuan" — biar aman,
// keduanya dihitung, tinggal pilih salah satu buat ditampilkan di UI.
Map<String, dynamic> hitungUmur(DateTime lahir, {DateTime? sekarangParam}) {
  DateTime sekarang = sekarangParam ?? DateTime.now();

  // --- Breakdown bertingkat (tahun, bulan, hari, lalu sisa jam/menit/detik) ---
  int tahun = sekarang.year - lahir.year;
  int bulan = sekarang.month - lahir.month;
  int hari = sekarang.day - lahir.day;

  if (hari < 0) {
    bulan -= 1;
    int bulanSebelumnya = sekarang.month - 1;
    int tahunAcuan = sekarang.year;
    if (bulanSebelumnya == 0) {
      bulanSebelumnya = 12;
      tahunAcuan -= 1;
    }
    int jumlahHariBulanSebelumnya = DateTime(tahunAcuan, bulanSebelumnya + 1, 0).day;
    hari += jumlahHariBulanSebelumnya;
  }
  if (bulan < 0) {
    tahun -= 1;
    bulan += 12;
  }

  // Sisa waktu (jam/menit/detik) dihitung dari selisih exact,
  // supaya presisi walau 'lahir' punya komponen jam/menit/detik.
  DateTime tandaYMD = DateTime(
    lahir.year + tahun,
    lahir.month + bulan,
    lahir.day + hari,
    lahir.hour,
    lahir.minute,
    lahir.second,
  );
  Duration sisa = sekarang.difference(tandaYMD);
  int jam = sisa.inHours;
  int menit = sisa.inMinutes % 60;
  int detik = sisa.inSeconds % 60;

  // --- Total per satuan (dihitung dari total Duration sejak lahir) ---
  Duration totalDurasi = sekarang.difference(lahir);

  return {
    'breakdown': {
      'tahun': tahun,
      'bulan': bulan,
      'hari': hari,
      'jam': jam,
      'menit': menit,
      'detik': detik,
    },
    'total': {
      'totalHari': totalDurasi.inDays,
      'totalJam': totalDurasi.inHours,
      'totalMenit': totalDurasi.inMinutes,
      'totalDetik': totalDurasi.inSeconds,
    },
  };
}

// ================= 2. KONVERSI HIJRIAH =================
// Port dari Kuwaiti Algorithm (tabular Islamic calendar), sumber:
// al-habib.info/islamic-calendar/hijricalendartext.htm
// Akurat +-1-2 hari dari kalender Umm al-Qura (bukan hasil rukyat asli).
double _floorDiv(double a, double b) => (a / b).floorToDouble();

List<String> namaBulanHijriah = [
  'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir',
  'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Syaban',
  'Ramadan', 'Syawal', 'Dzulkaidah', 'Dzulhijjah',
];

Map<String, dynamic> masehiKeHijriah(int tanggal, int bulan, int tahun) {
  double m = bulan.toDouble();
  double y = tahun.toDouble();
  if (m < 3) {
    y -= 1;
    m += 12;
  }

  double a = _floorDiv(y, 100);
  double b = 2 - a + _floorDiv(a, 4);
  if (y < 1583) b = 0;
  if (y == 1582) {
    if (m > 10) b = -10;
    if (m == 10) {
      b = 0;
      if (tanggal > 4) b = -10;
    }
  }

  double jd = _floorDiv(365.25 * (y + 4716), 1) +
      _floorDiv(30.6001 * (m + 1), 1) +
      tanggal + b - 1524;

  const double iyear = 10631 / 30;
  const double epochAstro = 1948084;
  const double shift1 = 8.01 / 60;

  double z = jd - epochAstro;
  double cyc = _floorDiv(z, 10631);
  z = z - 10631 * cyc;
  double j = _floorDiv(z - shift1, iyear);
  double iy = 30 * cyc + j;
  z = z - _floorDiv(j * iyear + shift1, 1);
  double im = _floorDiv(z + 28.5001, 29.5);
  if (im == 13) im = 12; // quirk algoritma asli, dipertahankan
  double id = z - _floorDiv(29.5001 * im - 29, 1);

  int bulanHijriah = im.toInt(); // 1-12, sudah sesuai indeks namaBulanHijriah (1-based)

  return {
    'tanggal': id.toInt(),
    'bulan': bulanHijriah,
    'namaBulan': namaBulanHijriah[bulanHijriah - 1],
    'tahun': iy.toInt(),
  };
}

// ================= 3. WETON (JAWA) =================
// CATATAN VERIFIKASI: anchor awal saya coba pakai "1 Jan 1970 = Kamis
// Kliwon" (klaim dari hitunganweton.id), tapi begitu di-cross-check ke
// fakta yang JAUH lebih terverifikasi (17 Agustus 1945 = Jumat Legi —
// dikonfirmasi 5+ sumber independen, termasuk almnk.com & ki-demang.com
// yang punya sistem konversi kalender Jawa sendiri), hasilnya meleset
// (dapat Pahing, bukan Legi). Jadi klaim "1970 = Kamis Kliwon" itu SALAH
// atau pakai konvensi berbeda — saya pakai anchor 17 Agustus 1945 sebagai
// gantinya karena lebih kuat buktinya.
List<String> namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
List<String> namaPasaran = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon']; // urutan sesuai anchor

Map<String, String> hitungWeton(DateTime tanggal) {
  String hari = namaHari[tanggal.weekday - 1]; // DateTime.weekday: Senin=1..Minggu=7

  DateTime anchor = DateTime(1945, 8, 17); // Jumat Legi (dikonfirmasi banyak sumber independen)
  int selisihHari = tanggal.difference(anchor).inDays;
  int indexPasaran = selisihHari % 5;
  if (indexPasaran < 0) indexPasaran += 5;
  String pasaran = namaPasaran[indexPasaran];

  return {'hari': hari, 'pasaran': pasaran, 'weton': '$hari $pasaran'};
}

// ================= 4. WUKU / PAWUKON (pendekatan Saka Bali) =================
// CATATAN PENTING buat laporan: ini BUKAN kalender Saka Bali penuh
// (yang lunisolar dan jauh lebih kompleks). Ini pendekatan siklus
// Pawukon (210 hari, 30 wuku x 7 hari) yang dipakai bersama sebagai
// salah satu unsur penanggalan Bali. Disclose ini eksplisit di laporan.
List<String> namaWuku = [
  'Sinta', 'Landep', 'Ukir', 'Kulantir', 'Tolu', 'Gumbreg', 'Wariga',
  'Warigadean', 'Julungwangi', 'Sungsang', 'Dungulan', 'Kuningan',
  'Langkir', 'Medangsia', 'Pujut', 'Pahang', 'Krulut', 'Merakih',
  'Tambir', 'Medangkungan', 'Matal', 'Uye', 'Menail', 'Perangbakat',
  'Bala', 'Ugu', 'Wayang', 'Kelawu', 'Dukut', 'Watugunung',
];

Map<String, dynamic> hitungWuku(DateTime tanggal) {
  DateTime anchor = DateTime(2000, 5, 21); // Wuku Sinta, indeks 0
  int selisihHari = tanggal.difference(anchor).inDays;
  int posisiSiklus = selisihHari % 210;
  if (posisiSiklus < 0) posisiSiklus += 210;

  int indexWuku = posisiSiklus ~/ 7; // 0-29
  int hariKe = (posisiSiklus % 7) + 1; // 1-7

  return {
    'namaWuku': namaWuku[indexWuku],
    'hariKe': hariKe,
    'nomorWuku': indexWuku + 1, // 1-30, buat ditampilkan ke user
  };
}

// ================= CLI: TEST SEMUA FUNGSI DI ATAS =================
void main() {
  print('=======================================');
  print('   TEST LOGIC KONVERSI TANGGAL (CLI)');
  print('=======================================');

  bool lanjut = true;
  while (lanjut) {
    print('\nPilih menu:');
    print('1. Konversi Tanggal Lahir (Hijriah + Umur)');
    print('2. Konversi Kalender Budaya (Weton + Wuku/Pawukon)');
    print('0. Keluar');
    stdout.write('Pilihan: ');
    String pilihan = stdin.readLineSync()!.trim();

    if (pilihan == '0') {
      lanjut = false;
      continue;
    }

    if (pilihan != '1' && pilihan != '2') {
      print('Pilihan tidak dikenali.');
      continue;
    }

    stdout.write('Tanggal (1-31): ');
    int tgl = int.parse(stdin.readLineSync()!);
    stdout.write('Bulan (1-12): ');
    int bln = int.parse(stdin.readLineSync()!);
    stdout.write('Tahun: ');
    int thn = int.parse(stdin.readLineSync()!);

    String? error = validasiTanggal(tgl, bln, thn);
    if (error != null) {
      print('[GAGAL] $error');
      continue;
    }

    DateTime tanggalValid = DateTime(thn, bln, tgl);

    if (pilihan == '1') {
      Map<String, dynamic> hijriah = masehiKeHijriah(tgl, bln, thn);
      Map<String, dynamic> umur = hitungUmur(tanggalValid);
      Map<String, dynamic> bd = umur['breakdown'];
      Map<String, dynamic> tot = umur['total'];

      print('\n--- HIJRIAH ---');
      print('${hijriah['tanggal']} ${hijriah['namaBulan']} ${hijriah['tahun']} H');

      print('\n--- UMUR (breakdown) ---');
      print('${bd['tahun']} tahun, ${bd['bulan']} bulan, ${bd['hari']} hari, '
          '${bd['jam']} jam, ${bd['menit']} menit, ${bd['detik']} detik');

      print('\n--- UMUR (total per satuan) ---');
      print('${tot['totalHari']} hari total');
      print('${tot['totalJam']} jam total');
      print('${tot['totalMenit']} menit total');
      print('${tot['totalDetik']} detik total');
    } else {
      Map<String, String> weton = hitungWeton(tanggalValid);
      Map<String, dynamic> wuku = hitungWuku(tanggalValid);

      print('\n--- WETON (JAWA) ---');
      print(weton['weton']);

      print('\n--- WUKU / PAWUKON (pendekatan Saka Bali) ---');
      print('Wuku ${wuku['namaWuku']} (ke-${wuku['nomorWuku']} dari 30), hari ke-${wuku['hariKe']} dalam wuku itu.');
    }
  }

  print('\nSelesai. Kalau hasilnya udah cocok dengan referensi manual,');
  print('fungsi-fungsi di atas tinggal dipanggil dari layar Flutter.');
}