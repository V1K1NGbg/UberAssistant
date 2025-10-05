import 'dart:async';
import 'package:flutter/material.dart';

class CustomTimer {
  Timer? _timer;

  /// Starts a repeating timer
  /// [context] - required to show the notification
  /// [interval] - duration between reminders
  /// [title] - text of the notification
  void start({
    required BuildContext context,
    required Duration interval,
    required String title,
  }) {
    _timer = Timer.periodic(interval, (_) {
      _showOverlay(context, title);
    });
  }

  void cancel() {
    _timer?.cancel();
  }

  void _showOverlay(BuildContext context, String text) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}