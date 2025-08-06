import 'package:formz/formz.dart';

enum EventTitleValidationError { empty, tooLong }

class EventTitle extends FormzInput<String, EventTitleValidationError> {
  const EventTitle.pure() : super.pure('');
  const EventTitle.dirty([String value = '']) : super.dirty(value);

  @override
  EventTitleValidationError? validator(String value) {
    if (value.isEmpty) return EventTitleValidationError.empty;
    if (value.length > 100) return EventTitleValidationError.tooLong;
    return null;
  }
}