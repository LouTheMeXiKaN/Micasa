import 'package:formz/formz.dart';

enum MaxCapacityValidationError { invalid, tooSmall, tooLarge }

class MaxCapacity extends FormzInput<int?, MaxCapacityValidationError> {
  const MaxCapacity.pure() : super.pure(null);
  const MaxCapacity.dirty([int? value]) : super.dirty(value);

  @override
  MaxCapacityValidationError? validator(int? value) {
    if (value == null) return null; // Optional field
    if (value <= 0) return MaxCapacityValidationError.invalid;
    if (value < 2) return MaxCapacityValidationError.tooSmall;
    if (value > 10000) return MaxCapacityValidationError.tooLarge;
    return null;
  }
}