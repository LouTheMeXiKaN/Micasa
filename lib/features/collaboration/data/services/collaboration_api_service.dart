import '../../../../core/network/api_client.dart';
import '../models/collaborator_models.dart';
import '../models/position_models.dart';
import '../models/application_models.dart';

class CollaborationApiService {
  final ApiClient _apiClient;

  CollaborationApiService(this._apiClient);

  Future<CollaborationHubData> getCollaborationHubData(String eventId) async {
    // Use the /team endpoint which is the actual backend implementation
    final response = await _apiClient.dio.get('/events/$eventId/team');
    final data = response.data as Map<String, dynamic>;
    
    // Parse the confirmed team members
    final confirmedTeam = (data['confirmed_team'] as List? ?? [])
        .map((json) => Collaborator.fromJson(json as Map<String, dynamic>))
        .toList();
    
    // Separate co-hosts and regular team members
    final cohosts = confirmedTeam.where((c) => c.isCohost).toList();
    final teamMembers = confirmedTeam.where((c) => !c.isCohost).toList();
    
    // Parse open positions
    final openPositions = (data['open_positions'] as List? ?? [])
        .map((json) => OpenPosition.fromJson(json as Map<String, dynamic>))
        .toList();
    
    return CollaborationHubData(
      cohosts: cohosts,
      teamMembers: teamMembers,
      openPositions: openPositions,
    );
  }

  Future<OpenPosition> createPosition(CreatePositionRequest request) async {
    final response = await _apiClient.dio.post(
      '/events/${request.eventId}/positions',
      data: request.toJson(),
    );
    
    return OpenPosition.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OpenPosition> updatePosition(String positionId, UpdatePositionRequest request) async {
    final response = await _apiClient.dio.put(
      '/positions/$positionId',
      data: request.toJson(),
    );
    
    return OpenPosition.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePosition(String positionId) async {
    await _apiClient.dio.delete('/positions/$positionId');
  }

  Future<List<Application>> getApplicationsForPosition(String positionId) async {
    final response = await _apiClient.dio.get('/positions/$positionId/applications');
    
    return (response.data as List)
        .map((json) => Application.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    // Use POST /applications/:applicationId/manage endpoint
    await _apiClient.dio.post(
      '/applications/$applicationId/manage',
      data: {'action': status == ApplicationStatus.accepted ? 'accept' : 'decline'},
    );
  }
}