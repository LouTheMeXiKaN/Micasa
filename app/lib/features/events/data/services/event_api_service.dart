import '../../../../core/network/api_client.dart';
import '../models/event_models.dart';

class EventApiService {
  final ApiClient _apiClient;

  EventApiService(this._apiClient);

  Future<CreateEventResponse> createEvent(Event event) async {
    final response = await _apiClient.dio.post(
      '/events',
      data: event.toJson(),
    );
    
    // Dio Interceptors handle error scenarios automatically
    return CreateEventResponse.fromJson(response.data);
  }

  Future<Event> getEvent(String eventId) async {
    final response = await _apiClient.dio.get('/events/$eventId');
    return Event.fromJson(response.data);
  }

  Future<List<Event>> getUserEvents({
    String? status, // 'upcoming', 'past', 'pending'
    String? role,   // 'host', 'collaborator', 'attendee'
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (role != null) queryParams['role'] = role;

    final response = await _apiClient.dio.get(
      '/users/me/events',
      queryParameters: queryParams,
    );

    final List<dynamic> eventsJson = response.data['events'] as List<dynamic>;
    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }

  // Mock implementation for Stage 1
  Future<CreateEventResponse> createEventMock(Event event) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate successful creation - preserve all the data from creation
    final createdEvent = event.copyWith(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    
    return CreateEventResponse(event: createdEvent);
  }
}