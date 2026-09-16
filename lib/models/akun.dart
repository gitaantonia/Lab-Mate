class Akun {
  final int? id;
  final String username;
  final String password;
  final String role;
  final int? praktikanId;

  Akun({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.praktikanId,
  });

  // Dari database → menjadi object Akun
  factory Akun.fromMap(Map<String, dynamic> map) {
    return Akun(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      praktikanId: map['praktikan_id'],
    );
  }

  // Dari object Akun → menjadi data untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'praktikan_id': praktikanId,
    };
  }
}