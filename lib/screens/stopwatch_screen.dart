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
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = _stopwatch.isRunning;
    final hasStarted = _stopwatch.elapsedMilliseconds > 0;
    final formattedTime = _formatDuration(_stopwatch.elapsed);
    final fastestIndex = _getFastestLapIndex();
    final slowestIndex = _getSlowestLapIndex();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch Laboratorium'),
        centerTitle: true,
        actions: [
          if (_laps.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
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
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
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
                        ? colorScheme.primaryContainer
                        : (hasStarted ? colorScheme.errorContainer : colorScheme.surfaceContainerHighest),
                    borderRadius: BorderRadius.circular(20),
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
                            ? colorScheme.onPrimaryContainer
                            : (hasStarted ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant),
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
                              ? colorScheme.onPrimaryContainer
                              : (hasStarted ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Main Time Text
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: colorScheme.onSurface,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Menit : Detik . Milidetik',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
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
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    // Start/Pause Button (Primary Action)
                    FilledButton.icon(
                      onPressed: _toggleStopwatch,
                      icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(isRunning ? 'Jeda' : (hasStarted ? 'Lanjut' : 'Mulai')),
                      style: FilledButton.styleFrom(
                        backgroundColor: isRunning ? colorScheme.error : colorScheme.primary,
                        foregroundColor: isRunning ? colorScheme.onError : colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    // Lap Button
                    ElevatedButton.icon(
                      onPressed: (hasStarted && isRunning) ? _recordLap : null,
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Lap'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                Text(
                  'Catatan Lap (${_laps.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_laps.isNotEmpty)
                  Text(
                    'Putaran & Waktu Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Laps List or Empty State
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 64,
                          color: colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum Ada Catatan Waktu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tekan tombol "Lap" saat stopwatch berjalan\nuntuk mencatat interval praktikum.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _laps.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final lapNum = _laps.length - index;
                      final totalSplit = _laps[index];
                      final delta = _getLapDelta(index);

                      final isFastest = index == fastestIndex;
                      final isSlowest = index == slowestIndex;

                      Color? tileColor;
                      Widget? badgeWidget;

                      if (isFastest) {
                        tileColor = Colors.green.withAlpha(25);
                        badgeWidget = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Tercepat',
                            style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        );
                      } else if (isSlowest) {
                        tileColor = Colors.orange.withAlpha(25);
                        badgeWidget = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Terlambat',
                            style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      return Container(
                        color: tileColor,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.secondaryContainer,
                            foregroundColor: colorScheme.onSecondaryContainer,
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          trailing: Icon(
                            Icons.flag_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
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
