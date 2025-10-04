import 'customer_request.dart';

class Trip {
  final CustomerRequest request;
  final DateTime start;
  final Duration duration;
  final DateTime? completedAt;

  Trip({
    required this.request,
    required this.start,
    required this.duration,
    this.completedAt,
  });

  factory Trip.fromRequest(CustomerRequest req, DateTime start, Duration duration) =>
      Trip(request: req, start: start, duration: duration);

  // convenience getters for UI
  get from => request.from;
  get to => request.to;

  Duration remaining(DateTime now) {
    if (completedAt != null) return Duration.zero;
    final end = start.add(duration);
    final left = end.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  double progress(DateTime now) {
    if (completedAt != null) return 1.0;
    final elapsed = now.difference(start).inMilliseconds.clamp(0, duration.inMilliseconds);
    return duration.inMilliseconds == 0 ? 1.0 : elapsed / duration.inMilliseconds;
  }

  Trip completeNow() => Trip(
    request: request,
    start: start,
    duration: duration,
    completedAt: DateTime.now(),
  );
}
