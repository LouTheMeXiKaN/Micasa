import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../models/email.dart';
import '../../models/password.dart';
import '../../models/terms_acceptance.dart';
import 'signup_state.dart';
import '../../../../../core/error/failures.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(const SignUpState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
    ));
  }

  void termsAcceptanceChanged(bool value) {
    final termsAcceptance = TermsAcceptance.dirty(value);
    emit(state.copyWith(
      termsAcceptance: termsAcceptance,
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!Formz.validate([state.email, state.password, state.termsAcceptance])) {
       if (state.termsAcceptance.isNotValid) {
         emit(state.copyWith(
           status: FormzSubmissionStatus.failure,
           errorMessage: 'You must accept the terms and conditions.',
         ));
       }
      return;
    }
    
    // Prevent rapid duplicate submissions
    if (state.status.isInProgress) return;
    
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _authRepository.signUpWithEmail(
        email: state.email.value,
        password: state.password.value,
    );

    result.fold(
        (failure) {
        String errorMessage = failure.message;
        if (failure is EmailAlreadyInUseFailure) {
            // Specific handling for 409 Conflict
            errorMessage = 'This email is already in use.';
        }
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: errorMessage,
        ));
        },
        (_) {
        // Success. AuthBloc handles the navigation upon successful signup stream update.
        emit(state.copyWith(status: FormzSubmissionStatus.success));
        },
    );
  }
}