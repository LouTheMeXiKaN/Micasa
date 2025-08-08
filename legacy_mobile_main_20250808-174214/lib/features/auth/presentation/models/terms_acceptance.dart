import 'package:formz/formz.dart';

enum TermsAcceptanceValidationError { required }

class TermsAcceptance extends FormzInput<bool, TermsAcceptanceValidationError> {
  const TermsAcceptance.pure() : super.pure(false);
  const TermsAcceptance.dirty([bool value = false]) : super.dirty(value);

  @override
  TermsAcceptanceValidationError? validator(bool value) {
    return value ? null : TermsAcceptanceValidationError.required;
  }
}