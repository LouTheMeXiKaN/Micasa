import 'package:formz/formz.dart';

enum ProfitShareValidationError { invalid, tooHigh }

class ProfitShare extends FormzInput<String, ProfitShareValidationError> {
  const ProfitShare.pure() : super.pure('');
  const ProfitShare.dirty([String value = '']) : super.dirty(value);

  @override
  ProfitShareValidationError? validator(String value) {
    if (value.isEmpty) return null; // Optional field
    
    final numValue = double.tryParse(value);
    if (numValue == null || numValue < 0) {
      return ProfitShareValidationError.invalid;
    }
    if (numValue > 100) {
      return ProfitShareValidationError.tooHigh;
    }
    return null;
  }
}