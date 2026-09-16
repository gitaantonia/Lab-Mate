import 'package:flutter/material.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Membuka database
  final db = await DBHelper.instance.database;

  // Mengambil daftar tabel
  final tables = await db.rawQuery('''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
    AND name NOT LIKE 'sqlite_%'
    ORDER BY name
  ''');

  // Mengambil data akun
  final akun = await db.query('akun');

  print('==============================');
  print('TEST DATABASE LABMATE');
  print('==============================');

  print('Tabel yang berhasil dibuat:');
  for (final table in tables) {
    print(table['name']);
  }

  print('');
  print('Data akun:');
  print(akun);

  print('==============================');

  runApp(const LabMateTestApp());
}

class LabMateTestApp extends StatelessWidget {
  const LabMateTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Database LabMate berhasil dibuka!',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}