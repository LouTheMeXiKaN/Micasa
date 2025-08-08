import 'package:formz/formz.dart';

enum PhoneNumberValidationError { empty, invalid }

class PhoneNumber extends FormzInput<String, PhoneNumberValidationError> {
  const PhoneNumber.pure() : super.pure('');
  const PhoneNumber.dirty([String value = '']) : super.dirty(value);

  static final RegExp _phoneRegExp = RegExp(
    r'^\+?[1-9]\d{1,14}$', // E.164 format
  );

  @override
  PhoneNumberValidationError? validator(String value) {
    if (value.isEmpty) return PhoneNumberValidationError.empty;
    // Remove spaces and dashes for validation
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!_phoneRegExp.hasMatch(cleaned)) return PhoneNumberValidationError.invalid;
    return null;
  }
}