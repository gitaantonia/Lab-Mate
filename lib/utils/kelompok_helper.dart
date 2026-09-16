/// Helper untuk pembagian kelompok otomatis.
class KelompokHelper {
  /// Membagi praktikan ke dalam kelompok.
  ///
  /// Setiap kelompok berisi minimal 3 dan maksimal 4 anggota.
  ///
  /// Contoh:
  /// 6 praktikan  -> 3 + 3
  /// 7 praktikan  -> 4 + 3
  /// 8 praktikan  -> 4 + 4
  /// 10 praktikan -> 4 + 3 + 3
  /// 11 praktikan -> 4 + 4 + 3
  /// 12 praktikan -> 4 + 4 + 4
  static List<List<String>> bagiKelompok({
    required List<String> praktikanIds,
    int minAnggota = 3,
    int maxAnggota = 4,
  }) {
    if (praktikanIds.isEmpty) {
      return [];
    }

    final totalPraktikan = praktikanIds.length;

    // Menentukan jumlah kelompok paling sedikit
    // agar tidak ada kelompok yang berisi lebih dari 4 orang.
    int jumlahKelompok = (totalPraktikan / maxAnggota).ceil();

    // Mengecek apakah jumlah kelompok tersebut
    // masih memungkinkan setiap kelompok memiliki minimal 3 orang.
    final jumlahKelompokMaksimal =
        (totalPraktikan / minAnggota).floor();

    if (jumlahKelompok > jumlahKelompokMaksimal) {
      // Contoh 5 orang tidak dapat dibagi menjadi
      // kelompok berisi 3-4 orang.
      return [];
    }

    final List<List<String>> kelompok = [];

    // Membuat kelompok kosong.
    for (int i = 0; i < jumlahKelompok; i++) {
      kelompok.add([]);
    }

    // Membagi praktikan secara merata.
    for (int i = 0; i < totalPraktikan; i++) {
      kelompok[i % jumlahKelompok].add(praktikanIds[i]);
    }

    return kelompok;
  }

  /// Membuat nama kelompok berdasarkan indeks.
  ///
  /// indeks 0 -> Kelompok 1
  /// indeks 1 -> Kelompok 2
  static String buatNamaKelompok(int indeks) {
    return 'Kelompok ${indeks + 1}';
  }

  /// Memvalidasi hasil pembagian kelompok.
  ///
  /// Syarat:
  /// - Tidak ada kelompok kosong.
  /// - Setiap kelompok berisi 3-4 anggota.
  /// - Semua praktikan sudah terbagi.
  static bool validasiPembagian({
    required List<List<String>> kelompok,
    required int totalPraktikan,
    int minAnggota = 3,
    int maxAnggota = 4,
  }) {
    int totalAnggota = 0;

    for (final kg in kelompok) {
      // Kelompok tidak boleh kosong.
      if (kg.isEmpty) {
        return false;
      }

      // Jumlah anggota harus berada pada rentang 3-4.
      if (kg.length < minAnggota || kg.length > maxAnggota) {
        return false;
      }

      totalAnggota += kg.length;
    }

    // Semua praktikan harus masuk ke kelompok.
    return totalAnggota == totalPraktikan;
  }

  /// Menghitung rata-rata jumlah anggota setiap kelompok.
  static double hitungRataAnggota({
    required List<List<String>> kelompok,
  }) {
    if (kelompok.isEmpty) {
      return 0.0;
    }

    int totalAnggota = 0;

    for (final kg in kelompok) {
      totalAnggota += kg.length;
    }

    return totalAnggota / kelompok.length;
  }
}