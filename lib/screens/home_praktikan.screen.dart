import 'package:flutter/material.dart';

class HomePraktikanScreen extends StatelessWidget {
  const HomePraktikanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Praktikan'),
      ),
      body: const Center(
        child: Text(
          'Selamat datang, Praktikan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}