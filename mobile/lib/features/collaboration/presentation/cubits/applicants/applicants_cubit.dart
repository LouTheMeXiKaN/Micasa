import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/collaboration_repository.dart';
import '../../../data/models/application_models.dart';
import 'applicants_state.dart';

class ApplicantsCubit extends Cubit<ApplicantsState> {
  final CollaborationRepository _collaborationRepository;
  final String _positionId;

  ApplicantsCubit(
    this._collaborationRepository,
    String positionId,
  ) : _positionId = positionId,
      super(const ApplicantsState());

  Future<void> loadApplications() async {
    emit(state.copyWith(status: ApplicantsStatus.loading));
    
    final result = await _collaborationRepository.getApplicationsForPosition(_positionId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ApplicantsStatus.failure,
        errorMessage: failure.message,
      )),
      (applications) => emit(state.copyWith(
        status: ApplicantsStatus.success,
        applications: applications,
      )),
    );
  }

  void toggleCardExpansion(String applicationId) {
    final expandedCardIds = Set<String>.from(state.expandedCardIds);
    
    if (expandedCardIds.contains(applicationId)) {
      expandedCardIds.remove(applicationId);
    } else {
      expandedCardIds.add(applicationId);
    }
    
    emit(state.copyWith(expandedCardIds: expandedCardIds));
  }

  Future<void> acceptApplication(String applicationId) async {
    await _processApplication(applicationId, ApplicationStatus.accepted);
  }

  Future<void> declineApplication(String applicationId) async {
    await _processApplication(applicationId, ApplicationStatus.declined);
  }

  Future<void> _processApplication(String applicationId, ApplicationStatus newStatus) async {
    final processingIds = Set<String>.from(state.processingApplicationIds);
    processingIds.add(applicationId);
    emit(state.copyWith(processingApplicationIds: processingIds));

    final result = await _collaborationRepository.updateApplicationStatus(
      applicationId, 
      newStatus,
    );

    result.fold(
      (failure) {
        processingIds.remove(applicationId);
        emit(state.copyWith(
          processingApplicationIds: processingIds,
          errorMessage: failure.message,
        ));
      },
      (_) {
        // Remove the processed application from the list
        final updatedApplications = state.applications
            .where((app) => app.id != applicationId)
            .toList();
        
        processingIds.remove(applicationId);
        emit(state.copyWith(
          applications: updatedApplications,
          processingApplicationIds: processingIds,
        ));
      },
    );
  }

  void refresh() => loadApplications();
}