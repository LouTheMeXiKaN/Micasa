import 'package:formz/formz.dart';

enum RoleTitleValidationError { empty, tooLong }

class RoleTitle extends FormzInput<String, RoleTitleValidationError> {
  const RoleTitle.pure() : super.pure('');
  const RoleTitle.dirty([String value = '']) : super.dirty(value);

  static const int maxLength = 30;

  @override
  RoleTitleValidationError? validator(String value) {
    if (value.isEmpty) return RoleTitleValidationError.empty;
    if (value.length > maxLength) return RoleTitleValidationError.tooLong;
    return null;
  }
}