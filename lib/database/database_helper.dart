import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // Singleton
  static final DBHelper instance = DBHelper._init();

  // Menyimpan koneksi database
  static Database? _database;

  // Constructor private
  DBHelper._init();

  // Mengambil database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('labmate.db');
    return _database!;
  }

  // Membuka database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  // Membuat semua tabel
  Future<void> _createDB(Database db, int version) async {
    // =========================
    // 1. MATA PRAKTIKUM
    // =========================
    await db.execute('''
      CREATE TABLE mata_praktikum (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE
      )
    ''');

    // =========================
    // 2. KOMPONEN BOBOT
    // =========================
    await db.execute('''
      CREATE TABLE komponen_bobot (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mata_praktikum_id INTEGER NOT NULL,
        nama_komponen TEXT NOT NULL,
        bobot REAL NOT NULL,
        FOREIGN KEY (mata_praktikum_id)
          REFERENCES mata_praktikum(id)
          ON DELETE CASCADE
      )
    ''');

    // =========================
    // 3. PRAKTIKAN
    // =========================
    await db.execute('''
      CREATE TABLE praktikan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mata_praktikum_id INTEGER NOT NULL,
        nim TEXT NOT NULL UNIQUE,
        nama TEXT NOT NULL,
        kelompok TEXT DEFAULT '-',
        nilai_akhir REAL DEFAULT 0.0,
        FOREIGN KEY (mata_praktikum_id)
          REFERENCES mata_praktikum(id)
          ON DELETE CASCADE
      )
    ''');

    // =========================
    // 4. AKUN
    // =========================
    await db.execute('''
      CREATE TABLE akun (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        praktikan_id INTEGER,
        FOREIGN KEY (praktikan_id)
          REFERENCES praktikan(id)
          ON DELETE CASCADE
      )
    ''');

    // =========================
    // 5. NILAI KOMPONEN
    // =========================
    await db.execute('''
      CREATE TABLE nilai_komponen (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        praktikan_id INTEGER NOT NULL,
        komponen_bobot_id INTEGER NOT NULL,
        skor REAL DEFAULT 0.0,
        UNIQUE(praktikan_id, komponen_bobot_id),
        FOREIGN KEY (praktikan_id)
          REFERENCES praktikan(id)
          ON DELETE CASCADE,
        FOREIGN KEY (komponen_bobot_id)
          REFERENCES komponen_bobot(id)
          ON DELETE CASCADE
      )
    ''');

    // =========================
    // DATA AWAL ASLAB
    // =========================
    await db.insert('akun', {
      'username': 'aslab',
      'password': '12345',
      'role': 'aslab',
      'praktikan_id': null,
    });
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;

    final result = await db.query(
      'akun',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // =========================================================
  // MATA PRAKTIKUM
  // =========================================================

  Future<int> tambahMataPraktikum(String nama) async {
    final db = await database;

    return await db.insert('mata_praktikum', {'nama': nama});
  }

  Future<List<Map<String, dynamic>>> getMataPraktikum() async {
    final db = await database;

    return await db.query('mata_praktikum', orderBy: 'id ASC');
  }

  Future<int> updateMataPraktikum(int id, String nama) async {
    final db = await database;

    return await db.update(
      'mata_praktikum',
      {'nama': nama},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapusMataPraktikum(int id) async {
    final db = await database;

    return await db.delete('mata_praktikum', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================
  // KOMPONEN BOBOT
  // =========================================================

  Future<int> tambahKomponenBobot({
    required int mataPraktikumId,
    required String namaKomponen,
    required double bobot,
  }) async {
    final db = await database;

    return await db.insert('komponen_bobot', {
      'mata_praktikum_id': mataPraktikumId,
      'nama_komponen': namaKomponen,
      'bobot': bobot,
    });
  }

  Future<List<Map<String, dynamic>>> getKomponenBobot(
    int mataPraktikumId,
  ) async {
    final db = await database;

    return await db.query(
      'komponen_bobot',
      where: 'mata_praktikum_id = ?',
      whereArgs: [mataPraktikumId],
      orderBy: 'id ASC',
    );
  }

  Future<int> updateKomponenBobot({
    required int id,
    required String namaKomponen,
    required double bobot,
  }) async {
    final db = await database;

    return await db.update(
      'komponen_bobot',
      {'nama_komponen': namaKomponen, 'bobot': bobot},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapusKomponenBobot(int id) async {
    final db = await database;

    return await db.delete('komponen_bobot', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================
  // PRAKTIKAN
  // =========================================================

  Future<int> tambahPraktikan({
    required int mataPraktikumId,
    required String nim,
    required String nama,
  }) async {
    final db = await database;

    final praktikanId = await db.insert('praktikan', {
      'mata_praktikum_id': mataPraktikumId,
      'nim': nim,
      'nama': nama,
    });

    // Membuat akun praktikan otomatis
    await db.insert('akun', {
      'username': nim,
      'password': '12345',
      'role': 'praktikan',
      'praktikan_id': praktikanId,
    });

    return praktikanId;
  }

  Future<List<Map<String, dynamic>>> getPraktikan() async {
    final db = await database;

    return await db.query('praktikan', orderBy: 'id ASC');
  }

  Future<List<Map<String, dynamic>>> getPraktikanByMataPraktikum(
    int mataPraktikumId,
  ) async {
    final db = await database;

    return await db.query(
      'praktikan',
      where: 'mata_praktikum_id = ?',
      whereArgs: [mataPraktikumId],
      orderBy: 'id ASC',
    );
  }

  Future<int> updatePraktikan({
    required int id,
    required String nim,
    required String nama,
  }) async {
    final db = await database;

    final updatedRows = await db.update(
      'praktikan',
      {'nim': nim, 'nama': nama},
      where: 'id = ?',
      whereArgs: [id],
    );

    await db.update(
      'akun',
      {'username': nim},
      where: 'praktikan_id = ?',
      whereArgs: [id],
    );

    return updatedRows;
  }

  Future<int> hapusPraktikan(int id) async {
    final db = await database;

    return await db.delete('praktikan', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================
  // NILAI
  // =========================================================

  Future<int> simpanNilai({
    required int praktikanId,
    required int komponenBobotId,
    required double skor,
  }) async {
    final db = await database;

    return await db.insert('nilai_komponen', {
      'praktikan_id': praktikanId,
      'komponen_bobot_id': komponenBobotId,
      'skor': skor,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getNilaiPraktikan(int praktikanId) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT
        nilai_komponen.id,
        nilai_komponen.skor,
        komponen_bobot.nama_komponen,
        komponen_bobot.bobot
      FROM nilai_komponen
      INNER JOIN komponen_bobot
        ON nilai_komponen.komponen_bobot_id = komponen_bobot.id
      WHERE nilai_komponen.praktikan_id = ?
      ORDER BY komponen_bobot.id ASC
    ''',
      [praktikanId],
    );
  }

  // =========================================================
  // UPDATE NILAI AKHIR
  // =========================================================

  Future<int> updateNilaiAkhir({
    required int praktikanId,
    required double nilaiAkhir,
  }) async {
    final db = await database;

    return await db.update(
      'praktikan',
      {'nilai_akhir': nilaiAkhir},
      where: 'id = ?',
      whereArgs: [praktikanId],
    );
  }

  // =========================================================
  // UPDATE KELOMPOK
  // =========================================================

  Future<int> updateKelompok({
    required int praktikanId,
    required String kelompok,
  }) async {
    final db = await database;

    return await db.update(
      'praktikan',
      {'kelompok': kelompok},
      where: 'id = ?',
      whereArgs: [praktikanId],
    );
  }
}
