/// Helper untuk perhitungan nilai dengan bobot.
class KomputasiHelper {
  /// Menghitung nilai akhir berdasarkan skor dan bobot.
  ///
  /// Rumus:
  /// Nilai Akhir = Σ(Skor × Bobot) / ΣBobot
  ///
  /// Contoh:
  /// Tugas = 85, bobot = 20
  /// Kuis  = 90, bobot = 30
  ///
  /// (85 × 20 + 90 × 30) / (20 + 30)
  static double hitungNilaiAkhir({
    required List<Map<String, dynamic>> nilaiKomponen,
  }) {
    if (nilaiKomponen.isEmpty) {
      return 0.0;
    }

    double totalNilaiTerbobot = 0.0;
    double totalBobot = 0.0;

    for (final item in nilaiKomponen) {
      // Data dari SQLite bisa berupa int atau double.
      final skor = (item['skor'] as num?)?.toDouble() ?? 0.0;
      final bobot = (item['bobot'] as num?)?.toDouble() ?? 0.0;

      totalNilaiTerbobot += skor * bobot;
      totalBobot += bobot;
    }

    // Menghindari pembagian dengan 0.
    if (totalBobot == 0.0) {
      return 0.0;
    }

    return totalNilaiTerbobot / totalBobot;
  }

  /// Memeriksa apakah total bobot sama dengan 100%.
  static bool validasiTotalBobot({
    required List<Map<String, dynamic>> komponenBobot,
  }) {
    double totalBobot = 0.0;

    for (final item in komponenBobot) {
      totalBobot += (item['bobot'] as num?)?.toDouble() ?? 0.0;
    }

    return (totalBobot - 100.0).abs() < 0.01;
  }

  /// Mengubah skor menjadi persentase.
  static double hitungPersenNilai({
    required double skor,
    required double nilaiMaksimal,
  }) {
    if (nilaiMaksimal <= 0.0) {
      return 0.0;
    }

    return (skor / nilaiMaksimal) * 100.0;
  }

  /// Membulatkan nilai menjadi maksimal 2 angka di belakang koma.
  static double bulatkanNilai(double nilai) {
    return double.parse(nilai.toStringAsFixed(2));
  }

  /// Menentukan grade berdasarkan nilai akhir.
  ///
  /// Catatan:
  /// Interval ini digunakan sesuai implementasi sebelumnya.
  /// Jika draft tugas memiliki interval grade yang berbeda,
  /// bagian ini harus mengikuti draft tersebut.
  static String tentukanGrade(double nilaiAkhir) {
    if (nilaiAkhir >= 85.0) {
      return 'A';
    }

    if (nilaiAkhir >= 75.0) {
      return 'B';
    }

    if (nilaiAkhir >= 65.0) {
      return 'C';
    }

    if (nilaiAkhir >= 55.0) {
      return 'D';
    }

    return 'E';
  }

  /// Memeriksa apakah skor berada pada rentang 0-100.
  static bool validasiSkor(double skor) {
    return skor >= 0.0 && skor <= 100.0;
  }
}