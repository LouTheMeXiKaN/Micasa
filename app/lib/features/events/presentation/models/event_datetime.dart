import 'package:formz/formz.dart';

enum EventDateTimeValidationError { empty, pastDate, endBeforeStart }

class EventDateTime extends FormzInput<DateTime?, EventDateTimeValidationError> {
  const EventDateTime.pure() : super.pure(null);
  const EventDateTime.dirty([DateTime? value]) : super.dirty(value);

  @override
  EventDateTimeValidationError? validator(DateTime? value) {
    if (value == null) return EventDateTimeValidationError.empty;
    if (value.isBefore(DateTime.now())) return EventDateTimeValidationError.pastDate;
    return null;
  }
}

class EventDateTimeRange extends FormzInput<DateTimeRange?, EventDateTimeValidationError> {
  const EventDateTimeRange.pure() : super.pure(null);
  const EventDateTimeRange.dirty([DateTimeRange? value]) : super.dirty(value);

  @override
  EventDateTimeValidationError? validator(DateTimeRange? value) {
    if (value == null) return EventDateTimeValidationError.empty;
    if (value.start.isBefore(DateTime.now())) return EventDateTimeValidationError.pastDate;
    if (value.end.isBefore(value.start)) return EventDateTimeValidationError.endBeforeStart;
    return null;
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateTimeRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}