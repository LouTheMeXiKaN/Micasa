import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../models/email.dart';
import '../../models/password.dart';
import 'login_state.dart';
import '../../../../../core/error/failures.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(const LoginState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      // Formz validation status is derived, not directly set to success/failure here
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!Formz.validate([state.email, state.password])) return;
    
    // Prevent rapid duplicate submissions
    if (state.status.isInProgress) return;
    
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    final result = await _authRepository.signInWithEmail(
        email: state.email.value,
        password: state.password.value,
    );

    result.fold(
        (failure) {
        String errorMessage = failure.message;
        if (failure is InvalidCredentialsFailure) {
            errorMessage = 'Invalid email or password.';
        }
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: errorMessage,
        ));
        },
        (_) {
        // Success. AuthBloc handles the navigation upon successful login stream update.
        emit(state.copyWith(status: FormzSubmissionStatus.success));
        },
    );
  }
    
  // Handling Social Auth here as they share the loading state on the initial AuthScreen
  Future<void> logInWithGoogle() async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }

  Future<void> logInWithApple() async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    final result = await _authRepository.signInWithApple();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }
}