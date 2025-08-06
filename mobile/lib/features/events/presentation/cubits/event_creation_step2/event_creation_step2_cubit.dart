import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../data/models/event_models.dart';
import '../../../data/repositories/event_repository.dart';
import '../../models/max_capacity.dart';
import '../event_creation_step1/event_creation_step1_state.dart';
import 'event_creation_step2_state.dart';

class EventCreationStep2Cubit extends Cubit<EventCreationStep2State> {
  final EventRepository _eventRepository;

  EventCreationStep2Cubit(this._eventRepository) : super(const EventCreationStep2State());

  void locationVisibilityChanged(LocationVisibility visibility) {
    emit(state.copyWith(locationVisibility: visibility));
  }

  void pricingModelChanged(PricingModel model) {
    emit(state.copyWith(pricingModel: model));
  }

  void maxCapacityChanged(String value) {
    final int? capacity = value.isEmpty ? null : int.tryParse(value);
    final maxCapacity = MaxCapacity.dirty(capacity);
    emit(state.copyWith(maxCapacity: maxCapacity));
  }

  void guestListVisibilityChanged(GuestListVisibility visibility) {
    emit(state.copyWith(guestListVisibility: visibility));
  }

  void privacyChanged(EventPrivacy privacy) {
    emit(state.copyWith(privacy: privacy));
  }

  Future<Event?> publishEvent(EventCreationStep1State step1Data) async {
    if (!state.isValid) return null;
    
    if (state.status.isInProgress) return null;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    // Create Event object from both steps
    final event = Event(
      title: step1Data.title.value,
      description: step1Data.description.value,
      startTime: step1Data.startTime.value!,
      endTime: step1Data.endTime.value!,
      location: step1Data.location.value,
      // coverImageUrl will be handled later when we add image upload
      locationVisibility: state.locationVisibility,
      pricingModel: state.pricingModel,
      maxCapacity: state.maxCapacity.value,
      guestListVisibility: state.guestListVisibility,
      privacy: state.privacy,
      createdAt: DateTime.now(),
    );

    final result = await _eventRepository.createEvent(event);
    
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (createdEvent) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          createdEvent: createdEvent,
        ));
        return createdEvent;
      },
    );

    return result.fold(
      (failure) => null,
      (createdEvent) => createdEvent,
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}