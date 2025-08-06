import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/models/event_management_models.dart';
import '../../../data/models/event_stats.dart';
import '../../../data/models/user_role.dart';
import '../../../data/models/event_models.dart';
import 'event_management_event.dart';
import 'event_management_state.dart';

class EventManagementBloc extends Bloc<EventManagementEvent, EventManagementState> {
  final EventRepository _eventRepository;

  EventManagementBloc({
    required EventRepository eventRepository,
  }) : _eventRepository = eventRepository,
        super(const EventManagementState()) {
    on<LoadEventManagementData>(_onLoadEventManagementData);
    on<RefreshEventStats>(_onRefreshEventStats);
    on<ShareEventRequested>(_onShareEventRequested);
  }

  Future<void> _onLoadEventManagementData(
    LoadEventManagementData event,
    Emitter<EventManagementState> emit,
  ) async {
    emit(state.copyWith(status: EventManagementStatus.loading));

    try {
      final eventResult = await _eventRepository.getEventById(event.eventId);

      eventResult.fold(
        (failure) => emit(state.copyWith(
          status: EventManagementStatus.failure,
          errorMessage: failure.message,
        )),
        (eventData) {
          // For MVP, we'll use mock stats but real event data
          // TODO: Implement real stats endpoint in future iteration
          final stats = EventStats(
            registeredCount: 0, // Will be 0 for newly created events
            goingCount: 0,
            maybeCount: 0,
            teamSize: 1, // Just the host initially
            revenue: 0.0,
            hasGoing: eventData.pricingModel == PricingModel.freeRsvp ||
                      eventData.pricingModel == PricingModel.donationBased,
            hasMaybe: eventData.pricingModel == PricingModel.freeRsvp ||
                      eventData.pricingModel == PricingModel.donationBased,
          );

          // Since the user created the event, they are the host
          const userRole = UserEventRole.host;
          final permissions = UserEventPermissions.forRole(userRole);

          // Determine event phase based on current time
          final now = DateTime.now();
          final phase = now.isBefore(eventData.startTime)
              ? EventPhase.preEvent
              : now.isBefore(eventData.endTime)
                  ? EventPhase.liveEvent
                  : EventPhase.postEvent;

          final managementData = EventManagementData(
            event: eventData,
            stats: stats,
            userRole: userRole,
            permissions: permissions,
            phase: phase,
            userId: 'mock_user_123', // In real implementation, get from auth
          );

          emit(state.copyWith(
            status: EventManagementStatus.success,
            eventData: managementData,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: EventManagementStatus.failure,
        errorMessage: 'Failed to load event data: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshEventStats(
    RefreshEventStats event,
    Emitter<EventManagementState> emit,
  ) async {
    if (state.eventData != null) {
      // In real implementation, refresh stats from API
      // For now, just increment some mock stats
      final currentStats = state.eventData!.stats;
      final newStats = EventStats(
        registeredCount: currentStats.registeredCount + 1,
        goingCount: currentStats.goingCount + 1,
        maybeCount: currentStats.maybeCount,
        teamSize: currentStats.teamSize,
        revenue: currentStats.revenue + 50.0,
        hasGoing: currentStats.hasGoing,
        hasMaybe: currentStats.hasMaybe,
      );

      final updatedData = EventManagementData(
        event: state.eventData!.event,
        stats: newStats,
        userRole: state.eventData!.userRole,
        permissions: state.eventData!.permissions,
        phase: state.eventData!.phase,
        userId: state.eventData!.userId,
      );

      emit(state.copyWith(eventData: updatedData));
    }
  }

  Future<void> _onShareEventRequested(
    ShareEventRequested event,
    Emitter<EventManagementState> emit,
  ) async {
    try {
      await Share.share(
        event.shareUrl,
        subject: state.eventData?.event.title ?? 'Check out this event!',
      );
    } catch (e) {
      emit(state.copyWith(
        status: EventManagementStatus.failure,
        errorMessage: 'Failed to share event: ${e.toString()}',
      ));
    }
  }
}