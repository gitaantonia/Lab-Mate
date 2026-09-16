import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {
  // Menyimpan data login
  static Future<void> saveSession({
    required int akunId,
    required String username,
    required String role,
    int? praktikanId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLogin', true);
    await prefs.setInt('akunId', akunId);
    await prefs.setString('username', username);
    await prefs.setString('role', role);

    if (praktikanId != null) {
      await prefs.setInt('praktikanId', praktikanId);
    }
  }

  // Mengecek apakah sudah login
  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isLogin') ?? false;
  }

  // Mengambil username yang sedang login
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('username');
  }

  // Mengambil role yang sedang login
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('role');
  }

  // Mengambil ID akun
  static Future<int?> getAkunId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt('akunId');
  }

  // Mengambil ID praktikan
  static Future<int?> getPraktikanId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt('praktikanId');
  }

  // Menghapus session saat logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}