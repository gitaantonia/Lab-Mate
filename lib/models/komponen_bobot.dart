class KomponenBobot {
  final int? id;
  final int mataPraktikumId;
  final String namaKomponen;
  final double bobot;

  KomponenBobot({
    this.id,
    required this.mataPraktikumId,
    required this.namaKomponen,
    required this.bobot,
  });

  factory KomponenBobot.fromMap(Map<String, dynamic> map) {
    return KomponenBobot(
      id: map['id'],
      mataPraktikumId: map['mata_praktikum_id'],
      namaKomponen: map['nama_komponen'],
      bobot: (map['bobot'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mata_praktikum_id': mataPraktikumId,
      'nama_komponen': namaKomponen,
      'bobot': bobot,
    };
  }
}