import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../../data/models/event_models.dart';
import '../../models/max_capacity.dart';

class EventCreationStep2State extends Equatable {
  final LocationVisibility locationVisibility;
  final PricingModel pricingModel;
  final MaxCapacity maxCapacity;
  final GuestListVisibility guestListVisibility;
  final EventPrivacy privacy;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final Event? createdEvent;

  const EventCreationStep2State({
    this.locationVisibility = LocationVisibility.confirmedGuests,
    this.pricingModel = PricingModel.freeRsvp,
    this.maxCapacity = const MaxCapacity.pure(),
    this.guestListVisibility = GuestListVisibility.public,
    this.privacy = EventPrivacy.public,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.createdEvent,
  });

  bool get isValid {
    // For Stage 1 (Free RSVP only), we only validate the capacity
    return Formz.validate([maxCapacity]);
  }

  EventCreationStep2State copyWith({
    LocationVisibility? locationVisibility,
    PricingModel? pricingModel,
    MaxCapacity? maxCapacity,
    GuestListVisibility? guestListVisibility,
    EventPrivacy? privacy,
    FormzSubmissionStatus? status,
    String? errorMessage,
    Event? createdEvent,
  }) {
    return EventCreationStep2State(
      locationVisibility: locationVisibility ?? this.locationVisibility,
      pricingModel: pricingModel ?? this.pricingModel,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      guestListVisibility: guestListVisibility ?? this.guestListVisibility,
      privacy: privacy ?? this.privacy,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdEvent: createdEvent ?? this.createdEvent,
    );
  }

  @override
  List<Object?> get props => [
        locationVisibility,
        pricingModel,
        maxCapacity,
        guestListVisibility,
        privacy,
        status,
        errorMessage,
        createdEvent,
      ];
}