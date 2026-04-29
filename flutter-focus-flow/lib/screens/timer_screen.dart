import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';

enum TimerPhase { work, shortBreak, longBreak }

class TimerScreen extends HookWidget {
  const TimerScreen({super.key});

  static const workDuration = 25 * 60;
  static const shortBreakDuration = 5 * 60;
  static const longBreakDuration = 15 * 60;

  @override
  Widget build(BuildContext context) {
    final phase = useState(TimerPhase.work);
    final secondsRemaining = useState(_getDuration(phase.value));
    final isRunning = useState(false);
    final pomodoroCount = useState(0);

    useEffect(() {
      Timer? timer;
      if (isRunning.value && secondsRemaining.value > 0) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          secondsRemaining.value--;
          if (secondsRemaining.value == 0) {
            isRunning.value = false;
            _handlePhaseComplete(phase, pomodoroCount, secondsRemaining);
          }
        });
      }
      return () => timer?.cancel();
    }, [isRunning.value, secondsRemaining.value]);

    final duration = _getDuration(phase.value);
    final percent = 1 - (secondsRemaining.value / duration);

    return Scaffold(
      appBar: AppBar(title: const Text('FOCUS TIMER')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 140,
              lineWidth: 12,
              percent: percent,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(secondsRemaining.value),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonCyan,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _phaseLabel(phase.value),
                    style: const TextStyle(
                      color: AppTheme.grey,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              progressColor: _phaseColor(phase.value),
              backgroundColor: AppTheme.darkGrey,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isRunning.value ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: AppTheme.neonCyan,
                  ),
                  onPressed: () => isRunning.value = !isRunning.value,
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.restart_alt, size: 36, color: AppTheme.grey),
                  onPressed: () {
                    isRunning.value = false;
                    secondsRemaining.value = _getDuration(phase.value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Pomodoros: ${pomodoroCount.value}',
              style: const TextStyle(color: AppTheme.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static int _getDuration(TimerPhase phase) {
    return switch (phase) {
      TimerPhase.work => workDuration,
      TimerPhase.shortBreak => shortBreakDuration,
      TimerPhase.longBreak => longBreakDuration,
    };
  }

  static String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  static String _phaseLabel(TimerPhase phase) {
    return switch (phase) {
      TimerPhase.work => 'WORK SESSION',
      TimerPhase.shortBreak => 'SHORT BREAK',
      TimerPhase.longBreak => 'LONG BREAK',
    };
  }

  static Color _phaseColor(TimerPhase phase) {
    return switch (phase) {
      TimerPhase.work => AppTheme.neonCyan,
      TimerPhase.shortBreak => AppTheme.neonPurple,
      TimerPhase.longBreak => AppTheme.neonBlue,
    };
  }

  static void _handlePhaseComplete(
    ValueNotifier<TimerPhase> phase,
    ValueNotifier<int> pomodoroCount,
    ValueNotifier<int> secondsRemaining,
  ) {
    if (phase.value == TimerPhase.work) {
      pomodoroCount.value++;
      if (pomodoroCount.value % 4 == 0) {
        phase.value = TimerPhase.longBreak;
      } else {
        phase.value = TimerPhase.shortBreak;
      }
    } else {
      phase.value = TimerPhase.work;
    }
    secondsRemaining.value = _getDuration(phase.value);
  }
}