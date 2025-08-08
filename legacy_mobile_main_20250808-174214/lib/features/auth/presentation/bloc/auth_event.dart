import 'package:equatable/equatable.dart';
import '../../data/models/auth_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Triggered by the repository stream subscription
class AuthStatusChanged extends AuthEvent {
  final User? user;

  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {}