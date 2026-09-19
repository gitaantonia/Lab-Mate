import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_mate/screens/login_screen.dart';

void main() {
  testWidgets('menampilkan halaman login', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('LabMate'), findsOneWidget);
    expect(find.textContaining('Username'), findsOneWidget);
  });
}
