import 'package:equatable/equatable.dart';
import '../../../data/models/application_models.dart';

enum ApplicantsStatus { initial, loading, success, failure }

class ApplicantsState extends Equatable {
  final ApplicantsStatus status;
  final List<Application> applications;
  final String? errorMessage;
  final Set<String> expandedCardIds;
  final Set<String> processingApplicationIds;

  const ApplicantsState({
    this.status = ApplicantsStatus.initial,
    this.applications = const [],
    this.errorMessage,
    this.expandedCardIds = const {},
    this.processingApplicationIds = const {},
  });

  ApplicantsState copyWith({
    ApplicantsStatus? status,
    List<Application>? applications,
    String? errorMessage,
    Set<String>? expandedCardIds,
    Set<String>? processingApplicationIds,
  }) {
    return ApplicantsState(
      status: status ?? this.status,
      applications: applications ?? this.applications,
      errorMessage: errorMessage ?? this.errorMessage,
      expandedCardIds: expandedCardIds ?? this.expandedCardIds,
      processingApplicationIds: processingApplicationIds ?? this.processingApplicationIds,
    );
  }

  bool isCardExpanded(String applicationId) {
    return expandedCardIds.contains(applicationId);
  }

  bool isApplicationProcessing(String applicationId) {
    return processingApplicationIds.contains(applicationId);
  }

  @override
  List<Object?> get props => [
        status,
        applications,
        errorMessage,
        expandedCardIds,
        processingApplicationIds,
      ];
}