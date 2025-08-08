import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../models/email.dart';
import '../../models/password.dart';
import '../../models/terms_acceptance.dart';

class SignUpState extends Equatable {
  final Email email;
  final Password password;
  final TermsAcceptance termsAcceptance;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const SignUpState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.termsAcceptance = const TermsAcceptance.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  SignUpState copyWith({
    Email? email,
    Password? password,
    TermsAcceptance? termsAcceptance,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      termsAcceptance: termsAcceptance ?? this.termsAcceptance,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, termsAcceptance, status, errorMessage];
}