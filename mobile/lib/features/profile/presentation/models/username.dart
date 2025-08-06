import 'package:formz/formz.dart';

enum UsernameValidationError { empty, tooShort, invalid }

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');
  const Username.dirty([String value = '']) : super.dirty(value);

  static final RegExp _usernameRegExp = RegExp(
    r'^[a-zA-Z0-9_]+$',
  );

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) return UsernameValidationError.empty;
    if (value.length < 3) return UsernameValidationError.tooShort;
    if (!_usernameRegExp.hasMatch(value)) return UsernameValidationError.invalid;
    return null;
  }
}