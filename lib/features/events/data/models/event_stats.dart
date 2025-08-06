import 'package:equatable/equatable.dart';

class EventStats extends Equatable {
  final int registeredCount;
  final int goingCount;
  final int maybeCount;
  final int teamSize;
  final double revenue;
  final bool hasGoing; // For Free RSVP/Donation events
  final bool hasMaybe; // For Free RSVP/Donation events

  const EventStats({
    required this.registeredCount,
    this.goingCount = 0,
    this.maybeCount = 0,
    required this.teamSize,
    required this.revenue,
    this.hasGoing = false,
    this.hasMaybe = false,
  });

  String get registeredDisplay {
    if (hasGoing && hasMaybe) {
      return '$goingCount Going • $maybeCount Maybe';
    }
    return '$registeredCount';
  }

  factory EventStats.fromJson(Map<String, dynamic> json) {
    return EventStats(
      registeredCount: json['registered_count'] as int? ?? 0,
      goingCount: json['going_count'] as int? ?? 0,
      maybeCount: json['maybe_count'] as int? ?? 0,
      teamSize: json['team_size'] as int? ?? 1,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      hasGoing: json['has_going'] as bool? ?? false,
      hasMaybe: json['has_maybe'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        registeredCount,
        goingCount,
        maybeCount,
        teamSize,
        revenue,
        hasGoing,
        hasMaybe,
      ];
}