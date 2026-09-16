class MataPraktikum {
  final int? id;
  final String nama;

  MataPraktikum({
    this.id,
    required this.nama,
  });

  factory MataPraktikum.fromMap(Map<String, dynamic> map) {
    return MataPraktikum(
      id: map['id'],
      nama: map['nama'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}