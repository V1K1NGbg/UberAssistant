// timer_manager.dart
import 'package:flutter/material.dart';
import 'custom_timer.dart';

class TimerManager extends StatefulWidget {
  final Widget child;
  const TimerManager({required this.child, super.key});

  @override
  State<TimerManager> createState() => _TimerManagerState();
}

class _TimerManagerState extends State<TimerManager> {
  final CustomTimer breakTimer = CustomTimer();
  final CustomTimer waterTimer = CustomTimer();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2-hour break timer
      breakTimer.start(
        context: context,
        interval: const Duration(hours: 2),
        title: "Time to take a break",
      );

      // 2.5-hour water timer
      waterTimer.start(
        context: context,
        interval: const Duration(minutes: 150),
        title: "Time to drink water",
      );
    });
  }

  @override
  void dispose() {
    breakTimer.cancel();
    waterTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // just render the child (MaterialApp)
  }
}