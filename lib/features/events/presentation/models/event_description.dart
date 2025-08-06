import 'package:formz/formz.dart';

enum EventDescriptionValidationError { tooLong }

class EventDescription extends FormzInput<String, EventDescriptionValidationError> {
  const EventDescription.pure() : super.pure('');
  const EventDescription.dirty([String value = '']) : super.dirty(value);

  @override
  EventDescriptionValidationError? validator(String value) {
    if (value.length > 1000) return EventDescriptionValidationError.tooLong;
    return null;
  }
}