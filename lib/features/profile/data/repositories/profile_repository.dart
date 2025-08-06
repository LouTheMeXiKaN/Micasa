import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../services/profile_api_service.dart';
import '../../../auth/data/services/token_storage_service.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class ProfileRepository {
  final ProfileApiService _profileApiService;
  final TokenStorageService _tokenStorageService;
  final AuthRepository _authRepository;

  ProfileRepository({
    required ProfileApiService profileApiService,
    required TokenStorageService tokenStorageService,
    required AuthRepository authRepository,
  })  : _profileApiService = profileApiService,
        _tokenStorageService = tokenStorageService,
        _authRepository = authRepository;

  Future<Either<Failure, User>> updateProfile({
    required String username,
    required String phoneNumber,
  }) async {
    try {
      final user = await _profileApiService.updateProfile(
        username: username,
        phoneNumber: phoneNumber,
      );
      
      // Update stored user data
      final currentToken = await _tokenStorageService.getToken();
      if (currentToken != null) {
        await _tokenStorageService.saveAuthData(
          AuthResponse(user: user, token: currentToken),
        );
      }
      
      // Update auth stream
      _authRepository.updateUserStream(user);
      
      return Right(user);
    } on ServerException catch (e) {
      if (e.errorCode == 'USERNAME_TAKEN') {
        return Left(ServerFailure(
          message: 'This username is already taken',
          code: e.errorCode,
        ));
      }
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

}