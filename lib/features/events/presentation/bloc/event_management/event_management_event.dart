import 'package:equatable/equatable.dart';

abstract class EventManagementEvent extends Equatable {
  const EventManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventManagementData extends EventManagementEvent {
  final String eventId;

  const LoadEventManagementData(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class RefreshEventStats extends EventManagementEvent {
  final String eventId;

  const RefreshEventStats(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class ShareEventRequested extends EventManagementEvent {
  final String shareUrl;

  const ShareEventRequested(this.shareUrl);

  @override
  List<Object?> get props => [shareUrl];
}