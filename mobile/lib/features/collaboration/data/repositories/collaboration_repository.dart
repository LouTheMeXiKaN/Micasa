import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../services/collaboration_api_service.dart';
import '../models/collaborator_models.dart';
import '../models/position_models.dart';
import '../models/application_models.dart';

class CollaborationRepository {
  final CollaborationApiService _apiService;

  CollaborationRepository({required CollaborationApiService apiService})
      : _apiService = apiService;

  Future<Either<Failure, CollaborationHubData>> getCollaborationHubData(String eventId) async {
    try {
      final data = await _apiService.getCollaborationHubData(eventId);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, OpenPosition>> createPosition(CreatePositionRequest request) async {
    try {
      final position = await _apiService.createPosition(request);
      return Right(position);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, OpenPosition>> updatePosition(String positionId, UpdatePositionRequest request) async {
    try {
      final position = await _apiService.updatePosition(positionId, request);
      return Right(position);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, Unit>> deletePosition(String positionId) async {
    try {
      await _apiService.deletePosition(positionId);
      return const Right(unit);
    } on ServerException catch (e) {
      if (e.statusCode == 409) {
        return const Left(ServerFailure(
          message: 'Cannot delete position with existing applications', 
          code: 'POSITION_HAS_APPLICATIONS',
        ));
      }
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, List<Application>>> getApplicationsForPosition(String positionId) async {
    try {
      final applications = await _apiService.getApplicationsForPosition(positionId);
      return Right(applications);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, Unit>> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    try {
      await _apiService.updateApplicationStatus(applicationId, status);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }
}