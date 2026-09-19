import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _toggleStopwatch() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
      } else {
        _stopwatch.start();
        _startTimer();
      }
    });
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _timer?.cancel();
      _laps.clear();
    });
  }

  void _recordLap() {
    if (_stopwatch.isRunning || _stopwatch.elapsedMilliseconds > 0) {
      setState(() {
        _laps.insert(0, _stopwatch.elapsed);
      });
    }
  }

  void _clearLaps() {
    setState(() {
      _laps.clear();
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths = (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    final hours = duration.inHours;

    if (hours > 0) {
      final hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutes:$seconds.$hundredths';
    }
    return '$minutes:$seconds.$hundredths';
  }

  // Menghitung waktu durasi khusus untuk satu lap (selisih dari lap sebelumnya)
  Duration _getLapDelta(int indexFromTop) {
    // _laps tersimpan paling baru di index 0
    final actualIndex = _laps.length - 1 - indexFromTop;
    if (actualIndex == 0) {
      return _laps[_laps.length - 1];
    } else {
      final current = _laps[_laps.length - 1 - actualIndex];
      final previous = _laps[_laps.length - actualIndex];
      return current - previous;
    }
  }

  // Cari lap tercepat dan terlambat berdasarkan delta time
  int? _getFastestLapIndex() {
    if (_laps.length < 2) return null;
    int fastestIndex = 0;
    Duration minDelta = _getLapDelta(0);

    for (int i = 1; i < _laps.length; i++) {
      final delta = _getLapDelta(i);
      if (delta < minDelta) {
        minDelta = delta;
        fastestIndex = i;
      }
    }
    return fastestIndex;
  }

  int? _getSlowestLapIndex() {
    if (_laps.length < 2) return null;
    int slowestIndex = 0;
    Duration maxDelta = _getLapDelta(0);

    for (int i = 1; i < _laps.length; i++) {
      final delta = _getLapDelta(i);
      if (delta > maxDelta) {
        maxDelta = delta;
        slowestIndex = i;
      }
    }
    return slowestIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _stopwatch.isRunning;
    final hasStarted = _stopwatch.elapsedMilliseconds > 0;
    final formattedTime = _formatDuration(_stopwatch.elapsed);
    final fastestIndex = _getFastestLapIndex();
    final slowestIndex = _getSlowestLapIndex();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Stopwatch Laboratorium'),
        centerTitle: true,
        actions: [
          if (_laps.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Hapus Semua Lap',
              onPressed: _clearLaps,
            ),
        ],
      ),
      body: Column(
        children: [
          // Timer Main Gauge Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRunning
                        ? const Color(0xFFECFDF5)
                        : (hasStarted ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isRunning
                          ? const Color(0xFFA7F3D0)
                          : (hasStarted ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRunning
                            ? Icons.play_arrow_rounded
                            : (hasStarted ? Icons.pause_rounded : Icons.timer_outlined),
                        size: 16,
                        color: isRunning
                            ? const Color(0xFF059669)
                            : (hasStarted ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRunning
                            ? 'BERJALAN'
                            : (hasStarted ? 'DIJEDA' : 'SIAP'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: isRunning
                              ? const Color(0xFF059669)
                              : (hasStarted ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Main Time Text
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: Color(0xFF1E293B),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Menit : Detik . Milidetik',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 28),
                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reset Button
                    OutlinedButton.icon(
                      onPressed: hasStarted ? _resetStopwatch : null,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    // Start/Pause Button (Primary Action)
                    FilledButton.icon(
                      onPressed: _toggleStopwatch,
                      icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 22),
                      label: Text(isRunning ? 'Jeda' : (hasStarted ? 'Lanjut' : 'Mulai')),
                      style: FilledButton.styleFrom(
                        backgroundColor: isRunning ? const Color(0xFFE11D48) : const Color(0xFF1E40AF),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    // Lap Button
                    ElevatedButton.icon(
                      onPressed: (hasStarted && isRunning) ? _recordLap : null,
                      icon: const Icon(Icons.flag_outlined, size: 20),
                      label: const Text('Lap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF334155),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Laps Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_rounded, size: 18, color: Color(0xFF1E40AF)),
                    const SizedBox(width: 8),
                    Text(
                      'Catatan Lap (${_laps.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                if (_laps.isNotEmpty)
                  const Text(
                    'Putaran & Waktu Total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Laps List or Empty State
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum Ada Catatan Waktu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tekan tombol "Lap" saat stopwatch berjalan\nuntuk mencatat interval praktikum.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _laps.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lapNum = _laps.length - index;
                      final totalSplit = _laps[index];
                      final delta = _getLapDelta(index);

                      final isFastest = index == fastestIndex;
                      final isSlowest = index == slowestIndex;

                      Color cardBg = Colors.white;
                      Color borderColor = const Color(0xFFE2E8F0);
                      Widget? badgeWidget;

                      if (isFastest) {
                        cardBg = const Color(0xFFF0FDF4);
                        borderColor = const Color(0xFFBBF7D0);
                        badgeWidget = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: const Text(
                            'Tercepat',
                            style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                          ),
                        );
                      } else if (isSlowest) {
                        cardBg = const Color(0xFFFFFBEB);
                        borderColor = const Color(0xFFFDE68A);
                        badgeWidget = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: const Text(
                            'Terlambat',
                            style: TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isFastest
                                ? const Color(0xFFDCFCE7)
                                : (isSlowest ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF)),
                            foregroundColor: isFastest
                                ? const Color(0xFF16A34A)
                                : (isSlowest ? const Color(0xFFD97706) : const Color(0xFF1E40AF)),
                            radius: 18,
                            child: Text(
                              '#$lapNum',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '+${_formatDuration(delta)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              if (badgeWidget != null) ...[
                                const SizedBox(width: 8),
                                badgeWidget,
                              ],
                            ],
                          ),
                          subtitle: Text(
                            'Total: ${_formatDuration(totalSplit)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.flag_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
