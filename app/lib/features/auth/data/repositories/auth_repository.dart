import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_models.dart';
import '../services/auth_api_service.dart';
import '../services/token_storage_service.dart';

class AuthRepository {
  final AuthApiService _authApiService;
  final TokenStorageService _tokenStorageService;
  // Stream controller to manage the current user reactively
  final _userController = StreamController<User?>.broadcast();

  AuthRepository({
    required AuthApiService authApiService,
    required TokenStorageService tokenStorageService,
  })  : _authApiService = authApiService,
        _tokenStorageService = tokenStorageService;

  // The source of truth for the application's authentication state
  Stream<User?> get user async* {
    // Emit current persisted user immediately on startup, then stream updates
    final currentUser = await _tokenStorageService.getUser();
    yield currentUser;
    yield* _userController.stream;
  }

  // Helper to process successful authentication
  Future<void> _persistAuthData(AuthResponse authResponse) async {
    await _tokenStorageService.saveAuthData(authResponse);
    _userController.add(authResponse.user);
  }

  // Methods now return Either<Failure, Unit> for structured error handling
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    try {
      final authResponse = await _authApiService.signInWithGoogle();
      await _persistAuthData(authResponse);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, Unit>> signInWithApple() async {
     try {
      final authResponse = await _authApiService.signInWithApple();
      await _persistAuthData(authResponse);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, Unit>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _authApiService.signInWithEmail(
        email: email,
        password: password,
      );
      await _persistAuthData(authResponse);
      return const Right(unit);
    } on ServerException catch (e) {
      // Map specific API errors to domain failures
      if (e.statusCode == 401 || e.statusCode == 404 || e.errorCode == 'INVALID_CREDENTIALS') {
        return const Left(InvalidCredentialsFailure());
      }
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<Either<Failure, Unit>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _authApiService.signUpWithEmail(
        email: email,
        password: password,
      );
      await _persistAuthData(authResponse);
      return const Right(unit);
    } on ServerException catch (e) {
      // Map specific API errors (e.g., 409 Conflict) to domain failures
      if (e.statusCode == 409 || e.errorCode == 'EMAIL_IN_USE') {
        return const Left(EmailAlreadyInUseFailure());
      }
      return Left(ServerFailure(message: e.message, code: e.errorCode));
    }
  }

  Future<void> signOut() async {
    // Optionally call backend logout if token invalidation is needed
    await _tokenStorageService.clearAuthData();
    _userController.add(null);
  }

  // Method to update user stream when profile is updated externally
  void updateUserStream(User user) {
    _userController.add(user);
  }

  void dispose() => _userController.close();
}