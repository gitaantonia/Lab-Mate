import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/session_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LabMateApp());
}

class LabMateApp extends StatelessWidget {
  const LabMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LabMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionData?>(
      future: SessionHelper.ambil(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data;
        if (session == null ||
            (session.role != 'aslab' && session.role != 'praktikan')) {
          return const LoginScreen();
        }

        return MainShell(role: session.role);
      },
    );
  }
}
