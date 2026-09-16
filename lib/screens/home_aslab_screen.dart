import 'package:flutter/material.dart';

class HomeAslabScreen extends StatelessWidget {
  const HomeAslabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Aslab'),
      ),
      body: const Center(
        child: Text(
          'Selamat datang, Aslab',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}