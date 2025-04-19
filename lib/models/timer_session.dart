import 'package:uuid/uuid.dart';

class TimerSession {
  final String id;
  String name;
  final int intervalMinutes;
  final int durationMinutes;
  final DateTime createdAt;
  DateTime? startedAt;
  bool isActive;

  TimerSession({
    String? id,
    String? name,
    required this.intervalMinutes,
    required this.durationMinutes,
    DateTime? createdAt,
    this.startedAt,
    this.isActive = false,
  }) : id = id ?? const Uuid().v4(),
       name = name ?? _generateDefaultName(),
       createdAt = createdAt ?? DateTime.now();

  static String _generateDefaultName() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Morning Focus';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon Session';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening Sprint';
    } else {
      return 'Night Focus';
    }
  }

  void start() {
    isActive = true;
    startedAt = DateTime.now();
  }

  void stop() {
    isActive = false;
    startedAt = null;
  }

  int get remainingMinutes {
    if (!isActive || startedAt == null) return durationMinutes;

    final elapsedMinutes = DateTime.now().difference(startedAt!).inMinutes;
    return (durationMinutes - elapsedMinutes).clamp(0, durationMinutes);
  }

  double get progressPercentage {
    if (!isActive || startedAt == null) return 0.0;
    return 1.0 - (remainingMinutes / durationMinutes);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'intervalMinutes': intervalMinutes,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      id: json['id'],
      name: json['name'],
      intervalMinutes: json['intervalMinutes'],
      durationMinutes: json['durationMinutes'],
      createdAt: DateTime.parse(json['createdAt']),
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      isActive: json['isActive'] ?? false,
    );
  }
}
