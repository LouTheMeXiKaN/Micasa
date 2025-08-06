import 'package:equatable/equatable.dart';

enum UserEventRole { host, cohost, collaborator, attendee }

class UserEventPermissions extends Equatable {
  final bool canEditDetails;
  final bool canConfirmPayouts;
  final bool canCancelEvent;
  final bool canManageTeam;
  final bool canViewGuestList;
  final bool canMessageGuests;
  final bool canCheckInGuests;

  const UserEventPermissions({
    required this.canEditDetails,
    required this.canConfirmPayouts,
    required this.canCancelEvent,
    required this.canManageTeam,
    required this.canViewGuestList,
    required this.canMessageGuests,
    required this.canCheckInGuests,
  });

  factory UserEventPermissions.forRole(UserEventRole role) {
    switch (role) {
      case UserEventRole.host:
        return const UserEventPermissions(
          canEditDetails: true,
          canConfirmPayouts: true,
          canCancelEvent: true,
          canManageTeam: true,
          canViewGuestList: true,
          canMessageGuests: true,
          canCheckInGuests: true,
        );
      case UserEventRole.cohost:
        return const UserEventPermissions(
          canEditDetails: false,
          canConfirmPayouts: false,
          canCancelEvent: false,
          canManageTeam: true,
          canViewGuestList: true,
          canMessageGuests: true,
          canCheckInGuests: true,
        );
      default:
        return const UserEventPermissions(
          canEditDetails: false,
          canConfirmPayouts: false,
          canCancelEvent: false,
          canManageTeam: false,
          canViewGuestList: false,
          canMessageGuests: false,
          canCheckInGuests: false,
        );
    }
  }

  @override
  List<Object?> get props => [
        canEditDetails,
        canConfirmPayouts,
        canCancelEvent,
        canManageTeam,
        canViewGuestList,
        canMessageGuests,
        canCheckInGuests,
      ];
}