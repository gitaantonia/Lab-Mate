import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mate/database/database_helper.dart';
import 'package:lab_mate/screens/login_screen.dart';
import 'package:lab_mate/screens/nilai/komponen_bobot_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    final db = await DBHelper.instance.database;
    await db.delete('nilai_komponen');
    await db.delete('komponen_bobot');
    await db.delete('akun');
    await db.delete('praktikan');
    await db.delete('mata_praktikum');
  });

  testWidgets('menampilkan halaman login', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('LabMate'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
  });

  test('menyimpan praktikan dan komponen nilai dengan data nyata', () async {
    final db = await DBHelper.instance.database;
    final mataPraktikumId = await DBHelper.instance.tambahMataPraktikum(
      'Pemrograman Mobile',
    );

    final praktikanId = await DBHelper.instance.tambahPraktikan(
      mataPraktikumId: mataPraktikumId,
      nim: '2024010001',
      nama: 'Serena',
      tanggalLahir: '2001-01-01',
    );

    await DBHelper.instance.tambahKomponenBobot(
      mataPraktikumId: mataPraktikumId,
      namaKomponen: 'Tugas',
      bobot: 30,
    );
    await DBHelper.instance.tambahKomponenBobot(
      mataPraktikumId: mataPraktikumId,
      namaKomponen: 'Project',
      bobot: 40,
    );

    final praktikan = await DBHelper.instance.getPraktikanByMataPraktikum(
      mataPraktikumId,
    );
    final komponen = await db.query('komponen_bobot');

    expect(praktikanId, isNotNull);
    expect(praktikan.first['nim'], '2024010001');
    expect(komponen.length, 2);
  });

  testWidgets('menampilkan layar kelola komponen bobot', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KomponenBobotScreen(mataPraktikumId: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Komponen Bobot Nilai'), findsOneWidget);
  });
}
