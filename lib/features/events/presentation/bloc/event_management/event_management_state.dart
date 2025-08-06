import 'package:equatable/equatable.dart';
import '../../../data/models/event_management_models.dart';

enum EventManagementStatus { initial, loading, success, failure }

class EventManagementState extends Equatable {
  final EventManagementStatus status;
  final EventManagementData? eventData;
  final String? errorMessage;

  const EventManagementState({
    this.status = EventManagementStatus.initial,
    this.eventData,
    this.errorMessage,
  });

  EventManagementState copyWith({
    EventManagementStatus? status,
    EventManagementData? eventData,
    String? errorMessage,
  }) {
    return EventManagementState(
      status: status ?? this.status,
      eventData: eventData ?? this.eventData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, eventData, errorMessage];
}