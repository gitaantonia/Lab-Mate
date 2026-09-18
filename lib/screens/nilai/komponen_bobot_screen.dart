import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class KomponenBobotScreen extends StatefulWidget {
  final int? mataPraktikumId;

  const KomponenBobotScreen({super.key, this.mataPraktikumId});

  @override
  State<KomponenBobotScreen> createState() => _KomponenBobotScreenState();
}

class _KomponenBobotScreenState extends State<KomponenBobotScreen> {
  late Future<List<Map<String, dynamic>>> _mataPraktikumFuture;
  late Future<List<Map<String, dynamic>>> _komponenFuture;
  int? _selectedMataPraktikumId;
  List<Map<String, dynamic>> _mataPraktikumList = [];

  @override
  void initState() {
    super.initState();
    _mataPraktikumFuture = DBHelper.instance.getMataPraktikum();
    _selectedMataPraktikumId = widget.mataPraktikumId;
    _komponenFuture = _loadKomponen();
  }

  Future<List<Map<String, dynamic>>> _loadKomponen() async {
    final id = _selectedMataPraktikumId;
    if (id == null) {
      return const [];
    }
    return DBHelper.instance.getKomponenBobot(id);
  }

  void _refresh() {
    setState(() {
      _komponenFuture = _loadKomponen();
    });
  }

  Future<void> _loadMataPraktikum() async {
    final list = await DBHelper.instance.getMataPraktikum();
    if (!mounted) return;

    setState(() {
      _mataPraktikumList = list;
      if (_selectedMataPraktikumId == null && list.isNotEmpty) {
        _selectedMataPraktikumId = list.first['id'] as int;
      }
      if (_selectedMataPraktikumId != null &&
          !_mataPraktikumList.any((item) => item['id'] == _selectedMataPraktikumId)) {
        _selectedMataPraktikumId = _mataPraktikumList.isNotEmpty
            ? (_mataPraktikumList.first['id'] as int)
            : null;
      }
      _komponenFuture = _loadKomponen();
    });
  }

  Future<void> _showForm({Map<String, dynamic>? item}) async {
    final namaController = TextEditingController(
      text: item != null ? (item['nama_komponen'] as String? ?? '') : '',
    );
    final bobotController = TextEditingController(
      text: item != null
          ? ((item['bobot'] as num?)?.toString() ?? '')
          : '',
    );

    if (_selectedMataPraktikumId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mata praktikum terlebih dahulu')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item == null ? 'Tambah Komponen Bobot' : 'Edit Komponen Bobot',
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Komponen',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bobotController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Bobot (%)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final nama = namaController.text.trim();
              final bobotText = bobotController.text.trim();
              final bobot = double.tryParse(bobotText);

              if (nama.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama komponen tidak boleh kosong')),
                );
                return;
              }

              if (bobot == null || bobot <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bobot harus lebih dari 0')),
                );
                return;
              }

              Navigator.pop(context, {'nama': nama, 'bobot': bobot});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    namaController.dispose();
    bobotController.dispose();

    if (result == null) return;

    final nama = result['nama'] as String;
    final bobot = (result['bobot'] as double).toDouble();

    if (item == null) {
      await DBHelper.instance.tambahKomponenBobot(
        mataPraktikumId: _selectedMataPraktikumId!,
        namaKomponen: nama,
        bobot: bobot,
      );
    } else {
      await DBHelper.instance.updateKomponenBobot(
        id: item['id'] as int,
        namaKomponen: nama,
        bobot: bobot,
      );
    }

    if (mounted) {
      _refresh();
    }
  }

  Future<void> _hapus(int id) async {
    await DBHelper.instance.hapusKomponenBobot(id);
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komponen Bobot Nilai'),
        centerTitle: true,
      ),
      floatingActionButton: _selectedMataPraktikumId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Komponen'),
            ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mataPraktikumFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat mata praktikum: ${snapshot.error}'),
            );
          }

          final mataPraktikumList = snapshot.data ?? [];
          if (mataPraktikumList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada mata praktikum.\nTambahkan mata praktikum terlebih dahulu.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (_selectedMataPraktikumId == null) {
            _selectedMataPraktikumId = mataPraktikumList.first['id'] as int;
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _komponenFuture,
            builder: (context, komponenSnapshot) {
              if (komponenSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (komponenSnapshot.hasError) {
                return Center(
                  child: Text('Gagal memuat komponen bobot: ${komponenSnapshot.error}'),
                );
              }

              final items = komponenSnapshot.data ?? [];

              if (items.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedMataPraktikumId,
                      decoration: const InputDecoration(
                        labelText: 'Mata Praktikum',
                        border: OutlineInputBorder(),
                      ),
                      items: mataPraktikumList.map((item) {
                        return DropdownMenuItem<int>(
                          value: item['id'] as int,
                          child: Text(item['nama'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedMataPraktikumId = value;
                          _komponenFuture = _loadKomponen();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text(
                              'Belum ada komponen bobot.\nTambahkan komponen seperti Tugas, Kuis, UTS, UAS.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () => _showForm(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Tambah Komponen'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              final totalBobot = items.fold<double>(0, (sum, item) {
                final bobot = (item['bobot'] as num?)?.toDouble() ?? 0.0;
                return sum + bobot;
              });

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedMataPraktikumId,
                    decoration: const InputDecoration(
                      labelText: 'Mata Praktikum',
                      border: OutlineInputBorder(),
                    ),
                    items: mataPraktikumList.map((item) {
                      return DropdownMenuItem<int>(
                        value: item['id'] as int,
                        child: Text(item['nama'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedMataPraktikumId = value;
                        _komponenFuture = _loadKomponen();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Bobot',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${totalBobot.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (totalBobot - 100).abs() < 0.01
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.map((item) {
                    final nama = item['nama_komponen'] as String? ?? 'Komponen';
                    final bobot = (item['bobot'] as num?)?.toDouble() ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Icon(Icons.assignment_rounded, color: Colors.blue.shade700),
                        ),
                        title: Text(nama),
                        subtitle: Text('${bobot.toStringAsFixed(0)}% bobot'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _showForm(item: item),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              onPressed: () => _hapus(item['id'] as int),
                              icon: const Icon(Icons.delete_rounded),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
