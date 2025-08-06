import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/collaboration_repository.dart';
import 'collaboration_hub_state.dart';

class CollaborationHubCubit extends Cubit<CollaborationHubState> {
  final CollaborationRepository _collaborationRepository;
  late final String _eventId;

  CollaborationHubCubit(
    this._collaborationRepository,
    String eventId,
  ) : _eventId = eventId,
      super(const CollaborationHubState());

  Future<void> loadCollaborationData() async {
    emit(state.copyWith(status: CollaborationHubStatus.loading));
    
    final result = await _collaborationRepository.getCollaborationHubData(_eventId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: CollaborationHubStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: CollaborationHubStatus.success,
        data: data,
      )),
    );
  }

  Future<void> deletePosition(String positionId) async {
    final result = await _collaborationRepository.deletePosition(positionId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: CollaborationHubStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        // Reload data after successful deletion
        loadCollaborationData();
      },
    );
  }

  void refresh() => loadCollaborationData();
}