import 'package:flutter/foundation.dart';
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
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite tidak didukung di mode web. Jalankan aplikasi di Android/Windows/Linux/macOS, atau ganti penyimpanan ke SharedPreferences/API.',
      );
    }

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
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE praktikan
      ADD COLUMN tanggal_lahir TEXT
    ''');
    }

    if (oldVersion < 3) {
      final mataPraktikum = await db.query('mata_praktikum');
      for (final mata in mataPraktikum) {
        await _buatKomponenBobotDefaultJikaBelumAda(db, mata['id'] as int);
      }
    }
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
  tanggal_lahir TEXT NOT NULL,
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
    await siapkanAkunPraktikanDemo();
    final db = await database;
    final normalizedUsername = username.trim();
    final normalizedPassword = password.trim();

    final result = await db.query(
      'akun',
      where: 'username = ? AND password = ?',
      whereArgs: [normalizedUsername, normalizedPassword],
      limit: 1,
    );

    if (result.isNotEmpty) return result.first;
    if (normalizedPassword != '12345') return null;

    final praktikan = await db.query(
      'praktikan',
      where: 'nim = ?',
      whereArgs: [normalizedUsername],
      limit: 1,
    );

    int praktikanId;
    if (praktikan.isEmpty) {
      // Auto-register NIM praktikan baru jika login pertama dengan password '12345'
      final listMp = await getMataPraktikum();
      final mpId = listMp.isNotEmpty ? listMp.first['id'] as int : 1;
      praktikanId = await db.insert('praktikan', {
        'mata_praktikum_id': mpId,
        'nim': normalizedUsername,
        'nama': 'Praktikan $normalizedUsername',
        'tanggal_lahir': '2002-05-15',
      });
    } else {
      praktikanId = praktikan.first['id'] as int;
    }

    final akun = await db.query(
      'akun',
      where: 'praktikan_id = ? OR username = ?',
      whereArgs: [praktikanId, normalizedUsername],
      limit: 1,
    );

    if (akun.isNotEmpty) {
      await db.update(
        'akun',
        {
          'username': normalizedUsername,
          'password': '12345',
          'role': 'praktikan',
          'praktikan_id': praktikanId,
        },
        where: 'id = ?',
        whereArgs: [akun.first['id'] as int],
      );
      return {
        ...akun.first,
        'username': normalizedUsername,
        'password': '12345',
        'role': 'praktikan',
        'praktikan_id': praktikanId,
      };
    }

    final akunId = await db.insert('akun', {
      'username': normalizedUsername,
      'password': '12345',
      'role': 'praktikan',
      'praktikan_id': praktikanId,
    });
    return {
      'id': akunId,
      'username': normalizedUsername,
      'password': '12345',
      'role': 'praktikan',
      'praktikan_id': praktikanId,
    };
  }

  Future<void> sinkronkanAkunPraktikan() async {
    final db = await database;
    final praktikan = await getPraktikan();

    for (final data in praktikan) {
      final praktikanId = data['id'] as int;
      final nim = data['nim'] as String;
      final akunByPraktikan = await db.query(
        'akun',
        where: 'praktikan_id = ?',
        whereArgs: [praktikanId],
        limit: 1,
      );

      if (akunByPraktikan.isNotEmpty) {
        await db.update(
          'akun',
          {'username': nim, 'password': '12345', 'role': 'praktikan'},
          where: 'id = ?',
          whereArgs: [akunByPraktikan.first['id'] as int],
        );
        continue;
      }

      final akunByUsername = await db.query(
        'akun',
        where: 'username = ?',
        whereArgs: [nim],
        limit: 1,
      );

      if (akunByUsername.isNotEmpty) {
        await db.update(
          'akun',
          {
            'password': '12345',
            'role': 'praktikan',
            'praktikan_id': praktikanId,
          },
          where: 'id = ?',
          whereArgs: [akunByUsername.first['id'] as int],
        );
      } else {
        await db.insert('akun', {
          'username': nim,
          'password': '12345',
          'role': 'praktikan',
          'praktikan_id': praktikanId,
        });
      }
    }
  }

  Future<void> siapkanAkunPraktikanDemo() async {
    final mataPraktikum = await getMataPraktikum();
    int mataPraktikumId;

    if (mataPraktikum.isEmpty) {
      mataPraktikumId = await tambahMataPraktikum('Pemrograman Mobile');
    } else {
      mataPraktikumId = mataPraktikum.first['id'] as int;
    }

    const dataDemo = [
      ('2024010001', 'Serena', '2001-01-01'),
      ('2024010002', 'Gita', '2001-02-02'),
      ('2024010003', 'Amalia', '2001-03-03'),
    ];

    final db = await database;
    for (final data in dataDemo) {
      final existing = await db.query(
        'praktikan',
        where: 'nim = ?',
        whereArgs: [data.$1],
        limit: 1,
      );

      if (existing.isEmpty) {
        await tambahPraktikan(
          mataPraktikumId: mataPraktikumId,
          nim: data.$1,
          nama: data.$2,
          tanggalLahir: data.$3,
        );
      }
    }

    await sinkronkanAkunPraktikan();
  }

  // =========================================================
  // MATA PRAKTIKUM
  // =========================================================

  Future<int> tambahMataPraktikum(String nama) async {
    final db = await database;

    final mataPraktikumId = await db.insert('mata_praktikum', {'nama': nama});
    await _buatKomponenBobotDefaultJikaBelumAda(db, mataPraktikumId);
    return mataPraktikumId;
  }

  Future<void> _buatKomponenBobotDefaultJikaBelumAda(
    Database db,
    int mataPraktikumId,
  ) async {
    final existing = await db.query(
      'komponen_bobot',
      where: 'mata_praktikum_id = ?',
      whereArgs: [mataPraktikumId],
      limit: 1,
    );

    if (existing.isNotEmpty) return;

    const komponenDefault = [
      {'nama_komponen': 'Tugas', 'bobot': 30.0},
      {'nama_komponen': 'Post-test', 'bobot': 30.0},
      {'nama_komponen': 'Project', 'bobot': 40.0},
    ];

    for (final komponen in komponenDefault) {
      await db.insert('komponen_bobot', {
        'mata_praktikum_id': mataPraktikumId,
        'nama_komponen': komponen['nama_komponen'],
        'bobot': komponen['bobot'],
      });
    }
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
    await _validasiTotalBobot(
      db,
      mataPraktikumId: mataPraktikumId,
      bobotBaru: bobot,
    );

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
    final komponen = await db.query(
      'komponen_bobot',
      columns: ['mata_praktikum_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (komponen.isNotEmpty) {
      await _validasiTotalBobot(
        db,
        mataPraktikumId: komponen.first['mata_praktikum_id'] as int,
        bobotBaru: bobot,
        komponenId: id,
      );
    }

    return await db.update(
      'komponen_bobot',
      {'nama_komponen': namaKomponen, 'bobot': bobot},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _validasiTotalBobot(
    Database db, {
    required int mataPraktikumId,
    required double bobotBaru,
    int? komponenId,
  }) async {
    final komponen = await db.query(
      'komponen_bobot',
      columns: ['id', 'bobot'],
      where: 'mata_praktikum_id = ?',
      whereArgs: [mataPraktikumId],
    );

    final totalBobot = komponen.fold<double>(0, (total, item) {
      if (item['id'] == komponenId) return total;
      return total + ((item['bobot'] as num?)?.toDouble() ?? 0.0);
    });

    if (totalBobot + bobotBaru > 100.01) {
      throw ArgumentError('Total bobot tidak boleh lebih dari 100%');
    }
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
    required String tanggalLahir,
  }) async {
    final db = await database;

    final praktikanId = await db.insert('praktikan', {
      'mata_praktikum_id': mataPraktikumId,
      'nim': nim,
      'nama': nama,
      'tanggal_lahir': tanggalLahir,
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
    required int mataPraktikumId,
    required String nim,
    required String nama,
    required String tanggalLahir,
  }) async {
    final db = await database;

    final updatedRows = await db.update(
      'praktikan',
      {
        'mata_praktikum_id': mataPraktikumId,
        'nim': nim,
        'nama': nama,
        'tanggal_lahir': tanggalLahir,
      },
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
  // =========================================================
  // DATA DUMMY UNTUK TESTING KOMPUTASI
  // =========================================================

  Future<void> tambahDataDummy() async {
    // Cek apakah akun demo sudah tersedia, termasuk pada database lama.
    final mataPraktikum = await getMataPraktikum();
    final praktikan = await getPraktikan();

    final demoSudahAda = praktikan.any((item) => item['nim'] == '2024010001');

    if (mataPraktikum.isNotEmpty && demoSudahAda) {
      await _pastikanAkunPraktikanDemo(praktikan);
      return;
    }

    // 1. Tambah Mata Praktikum
    final mataPraktikumId = await tambahMataPraktikum('Pemrograman Mobile');

    // 2. Tambah Praktikan
    await tambahPraktikan(
      mataPraktikumId: mataPraktikumId,
      nim: '2024010001',
      nama: 'Serena',
      tanggalLahir: '2001-01-01',
    );

    await tambahPraktikan(
      mataPraktikumId: mataPraktikumId,
      nim: '2024010002',
      nama: 'Gita',
      tanggalLahir: '2001-02-02',
    );

    await tambahPraktikan(
      mataPraktikumId: mataPraktikumId,
      nim: '2024010003',
      nama: 'Amalia',
      tanggalLahir: '2001-03-03',
    );
  }

  Future<void> _pastikanAkunPraktikanDemo(
    List<Map<String, dynamic>> praktikan,
  ) async {
    final db = await database;
    const demoNim = {'2024010001', '2024010002', '2024010003'};

    for (final data in praktikan) {
      final nim = data['nim'] as String;
      if (!demoNim.contains(nim)) continue;

      final praktikanId = data['id'] as int;
      final akun = await db.query(
        'akun',
        where: 'praktikan_id = ?',
        whereArgs: [praktikanId],
        limit: 1,
      );

      if (akun.isEmpty) {
        await db.insert('akun', {
          'username': nim,
          'password': '12345',
          'role': 'praktikan',
          'praktikan_id': praktikanId,
        });
      } else {
        await db.update(
          'akun',
          {'username': nim, 'password': '12345', 'role': 'praktikan'},
          where: 'id = ?',
          whereArgs: [akun.first['id'] as int],
        );
      }
    }
  }
}
