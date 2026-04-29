import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../controllers/timer_controller.dart';

class TimerScreen extends HookWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() => TimerController()..loadState());
    useEffect(() {
      return controller.dispose;
    }, [controller]);

    return Scaffold(
      appBar: AppBar(title: const Text('FOCUS TIMER')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final percent = controller.percent;
          final secondsRemaining = controller.secondsRemaining;
          final isRunning = controller.isRunning;
          final phase = controller.phase;
          final pomodoroCount = controller.pomodoroCount;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: controller.phaseColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularPercentIndicator(
                    radius: 140,
                    lineWidth: 12,
                    percent: percent,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.formatTime(secondsRemaining),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonCyan,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.phaseLabel,
                          style: const TextStyle(
                            color: AppTheme.grey,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    progressColor: controller.phaseColor,
                    backgroundColor: AppTheme.darkGrey,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isRunning ? Icons.pause : Icons.play_arrow,
                        size: 36,
                        color: AppTheme.neonCyan,
                      ),
                      onPressed: () {
                        if (isRunning) {
                          controller.pause();
                        } else {
                          controller.start();
                        }
                      },
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.restart_alt, size: 36, color: AppTheme.grey),
                      onPressed: () => controller.reset(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Pomodoros: $pomodoroCount',
                  style: const TextStyle(color: AppTheme.grey, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
