import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../models/username.dart';
import '../../models/phone_number.dart';
import 'profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  final ProfileRepository _profileRepository;

  ProfileSetupCubit(this._profileRepository) : super(const ProfileSetupState());

  void usernameChanged(String value) {
    final username = Username.dirty(value);
    emit(state.copyWith(
      username: username,
      errorMessage: null,
    ));
  }

  void phoneNumberChanged(String value) {
    final phoneNumber = PhoneNumber.dirty(value);
    emit(state.copyWith(
      phoneNumber: phoneNumber,
      errorMessage: null,
    ));
  }

  Future<void> submitProfile() async {
    if (!Formz.validate([state.username, state.phoneNumber])) return;
    
    if (state.status.isInProgress) return;
    
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    final result = await _profileRepository.updateProfile(
      username: state.username.value,
      phoneNumber: state.phoneNumber.value.replaceAll(RegExp(r'[\s-]'), ''),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) {
        // Success - the auth repository will update the user stream
        // which will trigger router to redirect to dashboard
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      },
    );
  }
}