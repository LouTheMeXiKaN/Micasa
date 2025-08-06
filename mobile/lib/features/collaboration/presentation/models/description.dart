import 'package:formz/formz.dart';

enum DescriptionValidationError { empty }

class Description extends FormzInput<String, DescriptionValidationError> {
  const Description.pure() : super.pure('');
  const Description.dirty([String value = '']) : super.dirty(value);

  @override
  DescriptionValidationError? validator(String value) {
    if (value.trim().isEmpty) return DescriptionValidationError.empty;
    return null;
  }
}