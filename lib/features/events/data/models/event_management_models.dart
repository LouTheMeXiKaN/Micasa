import 'package:equatable/equatable.dart';
import 'event_models.dart';
import 'event_stats.dart';
import 'user_role.dart';

enum EventPhase { preEvent, liveEvent, postEvent }

class EventManagementData extends Equatable {
  final Event event;
  final EventStats stats;
  final UserEventRole userRole;
  final UserEventPermissions permissions;
  final EventPhase phase;
  final String? userId; // For referral tracking

  const EventManagementData({
    required this.event,
    required this.stats,
    required this.userRole,
    required this.permissions,
    required this.phase,
    required this.userId,
  });

  String get userRoleDisplayName {
    switch (userRole) {
      case UserEventRole.host:
        return 'Host';
      case UserEventRole.cohost:
        return 'Co-host';
      case UserEventRole.collaborator:
        return 'Collaborator';
      case UserEventRole.attendee:
        return 'Attendee';
    }
  }

  bool get isDonationEvent => event.pricingModel == PricingModel.donationBased;

  String get shareUrl {
    final baseUrl = 'https://events.micasa.events/e/${event.id}';
    return userId != null ? '$baseUrl?ref=$userId' : baseUrl;
  }

  @override
  List<Object?> get props => [
        event,
        stats,
        userRole,
        permissions,
        phase,
        userId,
      ];
}