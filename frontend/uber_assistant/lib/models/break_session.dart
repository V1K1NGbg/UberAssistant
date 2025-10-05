class BreakSession {
  final DateTime start;
  final DateTime end;

  BreakSession(this.start, this.end);

  double get minutes => end.difference(start).inSeconds / 60.0;

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };

  factory BreakSession.fromJson(Map<String, dynamic> j) =>
      BreakSession(DateTime.parse(j['start'] as String), DateTime.parse(j['end'] as String));
}
