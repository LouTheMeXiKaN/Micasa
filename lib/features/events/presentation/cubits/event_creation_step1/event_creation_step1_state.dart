import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../models/event_title.dart';
import '../../models/event_description.dart';
import '../../models/event_location.dart';
import '../../models/event_datetime.dart';

class EventCreationStep1State extends Equatable {
  final File? coverImage;
  final EventTitle title;
  final EventDescription description;
  final EventDateTime startTime;
  final EventDateTime endTime;
  final EventLocation location;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const EventCreationStep1State({
    this.coverImage,
    this.title = const EventTitle.pure(),
    this.description = const EventDescription.pure(),
    this.startTime = const EventDateTime.pure(),
    this.endTime = const EventDateTime.pure(),
    this.location = const EventLocation.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  bool get isValid {
    return Formz.validate([title, location, startTime, endTime]) &&
           _isEndTimeAfterStartTime;
  }

  bool get _isEndTimeAfterStartTime {
    if (startTime.value == null || endTime.value == null) return true;
    return endTime.value!.isAfter(startTime.value!);
  }

  EventCreationStep1State copyWith({
    File? coverImage,
    EventTitle? title,
    EventDescription? description,
    EventDateTime? startTime,
    EventDateTime? endTime,
    EventLocation? location,
    FormzSubmissionStatus? status,
    String? errorMessage,
    bool clearCoverImage = false,
  }) {
    return EventCreationStep1State(
      coverImage: clearCoverImage ? null : (coverImage ?? this.coverImage),
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        coverImage,
        title,
        description,
        startTime,
        endTime,
        location,
        status,
        errorMessage,
      ];
}