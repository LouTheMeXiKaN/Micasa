import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../models/username.dart';
import '../../models/phone_number.dart';

class ProfileSetupState extends Equatable {
  final Username username;
  final PhoneNumber phoneNumber;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const ProfileSetupState({
    this.username = const Username.pure(),
    this.phoneNumber = const PhoneNumber.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  ProfileSetupState copyWith({
    Username? username,
    PhoneNumber? phoneNumber,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return ProfileSetupState(
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        username,
        phoneNumber,
        status,
        errorMessage,
      ];
}