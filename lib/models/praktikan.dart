class Praktikan {
  final int? id;
  final int mataPraktikumId;
  final String nim;
  final String nama;
  final String kelompok;
  final double nilaiAkhir;

  Praktikan({
    this.id,
    required this.mataPraktikumId,
    required this.nim,
    required this.nama,
    this.kelompok = '-',
    this.nilaiAkhir = 0.0,
  });

  factory Praktikan.fromMap(Map<String, dynamic> map) {
    return Praktikan(
      id: map['id'],
      mataPraktikumId: map['mata_praktikum_id'],
      nim: map['nim'],
      nama: map['nama'],
      kelompok: map['kelompok'] ?? '-',
      nilaiAkhir: (map['nilai_akhir'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mata_praktikum_id': mataPraktikumId,
      'nim': nim,
      'nama': nama,
      'kelompok': kelompok,
      'nilai_akhir': nilaiAkhir,
    };
  }
}