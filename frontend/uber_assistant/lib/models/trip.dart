import 'customer_request.dart';

class Trip {
  final CustomerRequest request;
  final DateTime startedAt;
  final Duration duration;

  Trip({required this.request, required this.startedAt, required this.duration});

  double progress(DateTime now) {
    final elapsed = now.difference(startedAt);
    final totalMs = duration.inMilliseconds;
    final p = (elapsed.inMilliseconds / totalMs).clamp(0.0, 1.0);
    return p.toDouble();
  }

  Duration remaining(DateTime now) {
    final left = duration - now.difference(startedAt);
    return left.isNegative ? Duration.zero : left;
  }

  bool get isDone => DateTime.now().isAfter(startedAt.add(duration));
}
