import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({required this.message, required this.code});

  @override
  List<Object> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, required String code})
      : super(message: message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message, required String code})
      : super(message: message, code: code);
}

// Specific Auth Failures mapped from API Contract 1.4 error codes
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure()
      : super(message: 'This email is already registered.', code: 'EMAIL_IN_USE');
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super(message: 'Invalid email or password.', code: 'INVALID_CREDENTIALS');
}