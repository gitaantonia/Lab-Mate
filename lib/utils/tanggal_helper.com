bool formatTanggalValid(String tanggal) {
  final regex = RegExp(
    r'^\d{4}-\d{2}-\d{2}$',
  );

  if (!regex.hasMatch(tanggal)) {
    return false;
  }

  try {
    final tahun = int.parse(
      tanggal.substring(0, 4),
    );

    final bulan = int.parse(
      tanggal.substring(5, 7),
    );

    final hari = int.parse(
      tanggal.substring(8, 10),
    );

    final date = DateTime(
      tahun,
      bulan,
      hari,
    );

    return date.year == tahun &&
        date.month == bulan &&
        date.day == hari;
  } catch (_) {
    return false;
  }
}

DateTime? parseTanggalLahir(String? tanggal) {
  if (tanggal == null) {
    return null;
  }

  final value = tanggal.trim();

  if (value.isEmpty) {
    return null;
  }

  if (!formatTanggalValid(value)) {
    return null;
  }

  final tahun = int.parse(
    value.substring(0, 4),
  );

  final bulan = int.parse(
    value.substring(5, 7),
  );

  final hari = int.parse(
    value.substring(8, 10),
  );

  return DateTime(
    tahun,
    bulan,
    hari,
  );
}

String formatTanggalIndonesia(String? tanggal) {
  final date = parseTanggalLahir(tanggal);

  if (date == null) {
    return 'Tanggal lahir belum tersedia';
  }

  const namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${date.day} '
      '${namaBulan[date.month - 1]} '
      '${date.year}';
}

int hitungUmur(String? tanggalLahir) {
  final tanggal = parseTanggalLahir(tanggalLahir);

  if (tanggal == null) {
    return 0;
  }

  final sekarang = DateTime.now();

  int umur =
      sekarang.year - tanggal.year;

  final belumUlangTahun =
      sekarang.month < tanggal.month ||
      (sekarang.month == tanggal.month &&
          sekarang.day < tanggal.day);

  if (belumUlangTahun) {
    umur--;
  }

  return umur;
}