import 'package:equatable/equatable.dart';
import '../../../data/models/collaborator_models.dart';

enum CollaborationHubStatus { initial, loading, success, failure }

class CollaborationHubState extends Equatable {
  final CollaborationHubStatus status;
  final CollaborationHubData? data;
  final String? errorMessage;

  const CollaborationHubState({
    this.status = CollaborationHubStatus.initial,
    this.data,
    this.errorMessage,
  });

  CollaborationHubState copyWith({
    CollaborationHubStatus? status,
    CollaborationHubData? data,
    String? errorMessage,
  }) {
    return CollaborationHubState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}