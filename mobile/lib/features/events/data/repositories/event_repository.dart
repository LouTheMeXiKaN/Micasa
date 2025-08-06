import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../models/event_models.dart';
import '../services/event_api_service.dart';

class EventRepository {
  final EventApiService _eventApiService;

  EventRepository({
    required EventApiService eventApiService,
  }) : _eventApiService = eventApiService;

  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      // Use the real API endpoint
      final response = await _eventApiService.createEvent(event);
      return Right(response.event);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to create event: ${e.toString()}', 
        code: 'CREATE_EVENT_ERROR'
      ));
    }
  }

  Future<Either<Failure, Event>> getEvent(String eventId) async {
    try {
      final event = await _eventApiService.getEvent(eventId);
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to fetch event', 
        code: 'FETCH_EVENT_ERROR'
      ));
    }
  }

  Future<Either<Failure, Event>> getEventById(String eventId) async {
    try {
      final event = await _eventApiService.getEvent(eventId);
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to fetch event', 
        code: 'FETCH_EVENT_ERROR'
      ));
    }
  }

  Future<Either<Failure, List<Event>>> getUserEvents({
    String? status,
    String? role,
  }) async {
    try {
      final events = await _eventApiService.getUserEvents(
        status: status,
        role: role,
      );
      return Right(events);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Failed to fetch events', 
        code: 'FETCH_EVENTS_ERROR'
      ));
    }
  }
}