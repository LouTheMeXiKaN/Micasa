import 'package:formz/formz.dart';

enum EventLocationValidationError { empty, tooLong }

class EventLocation extends FormzInput<String, EventLocationValidationError> {
  const EventLocation.pure() : super.pure('');
  const EventLocation.dirty([String value = '']) : super.dirty(value);

  @override
  EventLocationValidationError? validator(String value) {
    if (value.isEmpty) return EventLocationValidationError.empty;
    if (value.length > 200) return EventLocationValidationError.tooLong;
    return null;
  }
}