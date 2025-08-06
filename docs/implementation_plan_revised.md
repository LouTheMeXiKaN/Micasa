# Authentication Flow Implementation Plan (Revised)

## Overview
This document provides a detailed, architecturally robust implementation plan for the initial user authentication flow in the Micasa mobile app, corresponding to Screen 1 (Authentication Screen) and Screen 2 (Email Authentication Screen) as defined in the SL7.md document. This revised plan incorporates best practices for security, state management granularity (BLoC/Cubit with Formz), robust error handling, reactive authentication streams, and centralized navigation.

## 1. File Structure Overview

### New Files to Create:
```
lib/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── models/
│       │   │   └── auth_models.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── services/
│       │       ├── auth_api_service.dart
│       │       └── token_storage_service.dart
│       ├── presentation/
│       │   ├── bloc/ (Global Session Management)
│       │   │   ├── auth_bloc.dart
│       │   │   ├── auth_event.dart
│       │   │   └── auth_state.dart
│       │   ├── cubits/ (Form State Management)
│       │   │   ├── login/
│       │   │   │   ├── login_cubit.dart
│       │   │   │   └── login_state.dart
│       │   │   └── signup/
│       │   │       ├── signup_cubit.dart
│       │   │       └── signup_state.dart
│       │   ├── models/ (Formz Models)
│       │   │   ├── email.dart
│       │   │   ├── password.dart
│       │   │   └── terms_acceptance.dart
│       │   ├── screens/
│       │   │   ├── auth_screen.dart
│       │   │   └── email_auth_screen.dart
│       │   └── widgets/
│       │       ├── auth_button.dart
│       │       ├── social_auth_button.dart
│       │       └── auth_text_field.dart
├── core/
│   ├── config/
│   │   └── environment.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── api_client.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       └── validators.dart (Deprecated)
├── router/
│   └── app_router.dart
├── features/dashboard/presentation/screens/dashboard_screen.dart (Placeholder)
└── features/profile/presentation/screens/profile_setup_screen.dart (Placeholder)
```

### Existing Files to Modify:
- `lib/main.dart`
- `pubspec.yaml`

### New Configuration File:
- `.env` (New file for configuration)

## 2. Implementation Details

### 2.0 Core Infrastructure (New Section)

#### lib/core/config/environment.dart
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiBaseUrl {
    // Load API URL from .env file
    return dotenv.env['API_BASE_URL'] ?? 'https://api.micasa.events/v1';
  }
}
```

#### lib/core/error/failures.dart
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({required this.message, required this.code});

  @override
  List<Object> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, required String code})
      : super(message: message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message, required String code})
      : super(message: message, code: code);
}

// Specific Auth Failures mapped from API Contract 1.4 error codes
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure()
      : super(message: 'This email is already registered.', code: 'EMAIL_IN_USE');
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super(message: 'Invalid email or password.', code: 'INVALID_CREDENTIALS');
}
```

#### lib/core/error/exceptions.dart
```dart
// Used for catching errors at the boundary (API/Storage)
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String errorCode;

  ServerException({
    required this.message,
    this.statusCode,
    required this.errorCode,
  });
}

class CacheException implements Exception {}
```

#### lib/core/network/api_client.dart
```dart
import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../../features/auth/data/services/token_storage_service.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorageService _tokenStorageService;

  ApiClient(this._dio, this._tokenStorageService) {
    _dio.options.baseUrl = Environment.apiBaseUrl;
    _dio.options.headers = {'Content-Type': 'application/json'};
    
    // Add interceptors for authentication and error handling
    _dio.interceptors.add(AuthInterceptor(_tokenStorageService));
    _dio.interceptors.add(ErrorInterceptor());
    // NOTE: A TokenRefreshInterceptor should be implemented here to handle 401s transparently.
  }

  Dio get dio => _dio;
}

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorageService;

  AuthInterceptor(this._tokenStorageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

// Centralized error handling based on API Contract 1.4
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      // Parse standardized ErrorResponse schema
      final message = data['message'] ?? 'An unknown error occurred';
      final errorCode = data['error_code'] ?? 'UNKNOWN_ERROR';
      
      // Throw structured exception
      throw ServerException(
        message: message,
        statusCode: response.statusCode,
        errorCode: errorCode,
      );
    }
    
    // Handle network errors or other Dio errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      throw ServerException(message: 'Connection timed out', errorCode: 'TIMEOUT');
    }
    
    // Fallback for unhandled errors
    if (err.error is! ServerException) {
        throw ServerException(message: err.message ?? 'Network error', errorCode: 'NETWORK_ERROR');
    }
    
    super.onError(err, handler);
  }
}
```

### 2.1 Core Theme Files

#### lib/core/theme/app_colors.dart
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color deepPurple = Color(0xFF390F37);
  static const Color mediumPurple = Color(0xFF815288);
  static const Color lightPurple = Color(0xFFBD9FD1);
  
  // Accent Colors
  static const Color vibrantOrange = Color(0xFFFE4C01);
  static const Color warmOrange = Color(0xFFFF8A01);
  static const Color lightPeach = Color(0xFFFFB381);
  
  // Supporting Colors
  static const Color deepTeal = Color(0xFF003D59);
  static const Color forestGreen = Color(0xFF167070);
  static const Color sage = Color(0xFF44857D);
  
  // Feedback Colors
  static const Color coralRed = Color(0xFFFF5558);
  static const Color successGreen = Color(0xFF44857D);
  static const Color warningAmber = Color(0xFFFF8A01);
  
  // Neutrals
  static const Color neutral950 = Color(0xFF0A0809);
  static const Color neutral900 = Color(0xFF1A1618);
  static const Color neutral800 = Color(0xFF2B2529);
  static const Color neutral700 = Color(0xFF3C3539);
  static const Color neutral600 = Color(0xFF4D4649);
  static const Color neutral500 = Color(0xFF6B6565);
  static const Color neutral400 = Color(0xFF898383);
  static const Color neutral300 = Color(0xFFA7A1A1);
  static const Color neutral200 = Color(0xFFC5BFBF);
  static const Color neutral100 = Color(0xFFE3DDDD);
  static const Color neutral50 = Color(0xFFF5F2F2);
  
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
```

#### lib/core/theme/app_typography.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Base text styles
  static TextStyle get _baseTextStyle => GoogleFonts.inter();
  
  // Display font (Dallas Print Shop placeholder using similar serif)
  static TextStyle get displayFont => GoogleFonts.instrumentSerif();
  
  // Text scales - Mobile first
  static TextStyle get textXs => _baseTextStyle.copyWith(fontSize: 12);
  static TextStyle get textSm => _baseTextStyle.copyWith(fontSize: 14);
  static TextStyle get textBase => _baseTextStyle.copyWith(fontSize: 16);
  static TextStyle get textLg => _baseTextStyle.copyWith(fontSize: 18);
  static TextStyle get textXl => _baseTextStyle.copyWith(fontSize: 24);
  static TextStyle get text2xl => _baseTextStyle.copyWith(fontSize: 32);
  static TextStyle get text3xl => _baseTextStyle.copyWith(fontSize: 40);
  
  // Display text scales
  static TextStyle get displayXl => displayFont.copyWith(fontSize: 24);
  static TextStyle get display2xl => displayFont.copyWith(fontSize: 32);
  static TextStyle get display3xl => displayFont.copyWith(fontSize: 40);
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
```

#### lib/core/theme/app_theme.dart
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
  
  // Spacing
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 24.0;
  static const double space6 = 40.0;
  static const double space7 = 64.0;
  static const double space8 = 104.0;
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: AppColors.deepPurple.withOpacity(0.25),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepPurple,
        primary: AppColors.deepPurple,
        secondary: AppColors.vibrantOrange,
        surface: AppColors.white,
        background: AppColors.neutral50,
        error: AppColors.coralRed,
      ),
      scaffoldBackgroundColor: AppColors.neutral50,
      textTheme: TextTheme(
        displayLarge: AppTypography.display3xl.copyWith(color: AppColors.neutral950),
        displayMedium: AppTypography.display2xl.copyWith(color: AppColors.neutral950),
        displaySmall: AppTypography.displayXl.copyWith(color: AppColors.neutral950),
        headlineLarge: AppTypography.text3xl.copyWith(color: AppColors.neutral950),
        headlineMedium: AppTypography.text2xl.copyWith(color: AppColors.neutral950),
        headlineSmall: AppTypography.textXl.copyWith(color: AppColors.neutral950),
        titleLarge: AppTypography.textLg.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.semibold),
        titleMedium: AppTypography.textBase.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.semibold),
        titleSmall: AppTypography.textSm.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.semibold),
        bodyLarge: AppTypography.textBase.copyWith(color: AppColors.neutral950),
        bodyMedium: AppTypography.textSm.copyWith(color: AppColors.neutral950),
        bodySmall: AppTypography.textXs.copyWith(color: AppColors.neutral950),
        labelLarge: AppTypography.textBase.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.medium),
        labelMedium: AppTypography.textSm.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.medium),
        labelSmall: AppTypography.textXs.copyWith(color: AppColors.neutral950, fontWeight: AppTypography.medium),
      ),
    );
  }
}
```

### 2.2 Authentication State Management (Refactored)

This section is significantly refactored to separate the global authentication state (AuthBloc) from the screen-specific form states (LoginCubit, SignUpCubit), utilizing formz for validation.

#### 2.2.1 Form Models (using Formz)

##### lib/features/auth/presentation/models/email.dart
```dart
import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalid }

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');
  const Email.dirty([String value = '']) : super.dirty(value);

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!_emailRegExp.hasMatch(value)) return EmailValidationError.invalid;
    return null;
  }
}
```

##### lib/features/auth/presentation/models/password.dart
```dart
import 'package:formz/formz.dart';

enum PasswordValidationError { empty, short }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < 8) return PasswordValidationError.short;
    return null;
  }
}
```

##### lib/features/auth/presentation/models/terms_acceptance.dart
```dart
import 'package:formz/formz.dart';

enum TermsAcceptanceValidationError { required }

class TermsAcceptance extends FormzInput<bool, TermsAcceptanceValidationError> {
  const TermsAcceptance.pure() : super.pure(false);
  const TermsAcceptance.dirty([bool value = false]) : super.dirty(value);

  @override
  TermsAcceptanceValidationError? validator(bool value) {
    return value ? null : TermsAcceptanceValidationError.required;
  }
}
```

#### 2.2.2 Global AuthBloc (Session Management)

This BLoC now purely focuses on the session state derived from the repository's stream.

##### lib/features/auth/presentation/bloc/auth_event.dart
```dart
import 'package:equatable/equatable.dart';
import '../../data/models/auth_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Triggered by the repository stream subscription
class AuthStatusChanged extends AuthEvent {
  final User? user;

  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {}
```

##### lib/features/auth/presentation/bloc/auth_state.dart
```dart
import 'package:equatable/equatable.dart';
import '../../data/models/auth_models.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}
```

##### lib/features/auth/presentation/bloc/auth_bloc.dart
```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    // Subscribe to the reactive user stream from the repository
    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthStatusChanged(user)),
    );
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    // The stream listener (_onAuthStatusChanged) will handle the state change automatically.
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
```

#### 2.2.3 Login Cubit (Form State and OAuth Handling)

##### lib/features/auth/presentation/cubits/login/login_state.dart
```dart
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../models/email.dart';
import '../../models/password.dart';

class LoginState extends Equatable {
  final Email email;
  final Password password;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    Email? email,
    Password? password,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage];
}
```

##### lib/features/auth/presentation/cubits/login/login_cubit.dart
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../models/email.dart';
import '../../models/password.dart';
import 'login_state.dart';
import '../../../../../core/error/failures.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(const LoginState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      // Formz validation status is derived, not directly set to success/failure here
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!Formz.validate([state.email, state.password])) return;
    
    // Prevent rapid duplicate submissions
    if (state.status.isInProgress) return;
    
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    final result = await _authRepository.signInWithEmail(
        email: state.email.value,
        password: state.password.value,
    );

    result.fold(
        (failure) {
        String errorMessage = failure.message;
        if (failure is InvalidCredentialsFailure) {
            errorMessage = 'Invalid email or password.';
        }
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: errorMessage,
        ));
        },
        (_) {
        // Success. AuthBloc handles the navigation upon successful login stream update.
        emit(state.copyWith(status: FormzSubmissionStatus.success));
        },
    );
  }
    
  // Handling Social Auth here as they share the loading state on the initial AuthScreen
  Future<void> logInWithGoogle() async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }

  Future<void> logInWithApple() async {
    if (state.status.isInProgress) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    final result = await _authRepository.signInWithApple();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }
}
```

#### 2.2.4 SignUp Cubit (Form State)

##### lib/features/auth/presentation/cubits/signup/signup_state.dart
```dart
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../models/email.dart';
import '../../models/password.dart';
import '../../models/terms_acceptance.dart';

class SignUpState extends Equatable {
  final Email email;
  final Password password;
  final TermsAcceptance termsAcceptance;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const SignUpState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.termsAcceptance = const TermsAcceptance.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  SignUpState copyWith({
    Email? email,
    Password? password,
    TermsAcceptance? termsAcceptance,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      termsAcceptance: termsAcceptance ?? this.termsAcceptance,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, termsAcceptance, status, errorMessage];
}
```

##### lib/features/auth/presentation/cubits/signup/signup_cubit.dart
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../models/email.dart';
import '../../models/password.dart';
import '../../models/terms_acceptance.dart';
import 'signup_state.dart';
import '../../../../../core/error/failures.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(const SignUpState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
    ));
  }

  void termsAcceptanceChanged(bool value) {
    final termsAcceptance = TermsAcceptance.dirty(value);
    emit(state.copyWith(
      termsAcceptance: termsAcceptance,
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!Formz.validate([state.email, state.password, state.termsAcceptance])) {
       if (state.termsAcceptance.isNotValid) {
         emit(state.copyWith(
           status: FormzSubmissionStatus.failure,
           errorMessage: 'You must accept the terms and conditions.',
         ));
       }
      return;
    }
    
    // Prevent rapid duplicate submissions
    if (state.status.isInProgress) return;
    
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _authRepository.signUpWithEmail(
        email: state.email.value,
        password: state.password.value,
    );

    result.fold(
        (failure) {
        String errorMessage = failure.message;
        if (failure is EmailAlreadyInUseFailure) {
            // Specific handling for 409 Conflict
            errorMessage = 'This email is already in use.';
        }
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: errorMessage,
        ));
        },
        (_) {
        // Success. AuthBloc handles the navigation upon successful signup stream update.
        emit(state.copyWith(status: FormzSubmissionStatus.success));
        },
    );
  }
}
```

### 2.3 Data Layer (Refactored)

#### lib/features/auth/data/models/auth_models.dart
```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final String? bio;
  final bool isUsernameAutogenerated;
  final DateTime createdAt;

  const User({
    required this.id,
    this.username,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.bio,
    required this.isUsernameAutogenerated,
    required this.createdAt,
  });
  
  // Helper to check if profile initialization is needed (Screen 25 Gate)
  // This logic enforces the requirements defined in SL7.md for Screen 25.
  bool get requiresInitialization => isUsernameAutogenerated || phoneNumber == null || username == null;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      bio: json['bio'] as String?,
      isUsernameAutogenerated: json['is_username_autogenerated'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
      'bio': bio,
      'is_username_autogenerated': isUsernameAutogenerated,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        phoneNumber,
        profilePictureUrl,
        bio,
        isUsernameAutogenerated,
        createdAt,
      ];
      
  // Represents an empty user for initial states (if needed)
  static const empty = User(id: '', isUsernameAutogenerated: false, createdAt: DateTime.now());
}

// Kept for internal API responses
class AuthResponse {
  final User user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
```

#### lib/features/auth/data/services/token_storage_service.dart (New - SRP & Security)
```dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

// Handles secure storage of tokens using native encrypted storage (iOS Keychain / Android Keystore)
class TokenStorageService {
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  TokenStorageService(this._secureStorage);

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        // Handle potential parsing errors if JSON is corrupted
        await clearAuthData(); // Clear corrupted data
        return null;
      }
    }
    return null;
  }

  Future<void> saveAuthData(AuthResponse authResponse) async {
    await _secureStorage.write(key: _tokenKey, value: authResponse.token);
    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(authResponse.user.toJson()),
    );
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }
}
```

#### lib/features/auth/data/services/auth_api_service.dart (Refactored from AuthService)
```dart
import '../../../../core/network/api_client.dart';
import '../models/auth_models.dart';

// Handles only network communication using the centralized ApiClient (Dio)
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<AuthResponse> signInWithGoogle() async {
    // TODO: Implement actual Google OAuth flow client-side, then exchange token with backend
    // await _apiClient.dio.post('/auth/oauth', data: {'provider': 'google', 'token': googleToken});
    
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock response
    return AuthResponse(
      user: User(
        id: '123',
        username: 'google_user',
        email: 'user@gmail.com',
        isUsernameAutogenerated: true, // Crucial for forcing profile setup
        createdAt: DateTime.now(),
      ),
      token: 'mock_google_token',
    );
  }

  Future<AuthResponse> signInWithApple() async {
    // TODO: Implement actual Apple OAuth flow
    // await _apiClient.dio.post('/auth/oauth', data: {'provider': 'apple', 'token': appleToken});
    
    await Future.delayed(const Duration(seconds: 2));
        
    // Mock response
    return AuthResponse(
      user: User(
        id: '124',
        username: 'apple_user',
        email: 'user@icloud.com',
        isUsernameAutogenerated: true, // Crucial for forcing profile setup
        createdAt: DateTime.now(),
      ),
      token: 'mock_apple_token',
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    // Dio Interceptors handle error scenarios automatically
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );
    // Dio Interceptors handle error scenarios (like 409 Conflict) automatically
    return AuthResponse.fromJson(response.data);
  }
}
```

#### lib/features/auth/data/repositories/auth_repository.dart (Refactored for Streams and Error Handling)
```dart
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

  void dispose() => _userController.close();
}
```

### 2.4 UI Components

#### lib/features/auth/presentation/widgets/auth_button.dart
```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AuthButton extends StatelessWidget {
  final String text;
  // Changed to optional VoidCallback? to handle disabled state properly via Cubit
  final VoidCallback? onPressed; 
  final bool isLoading;
  final bool isPrimary;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Design System Adherence: "Intentionally imperfect border" for secondary buttons
    final borderRadius = isPrimary
        ? BorderRadius.circular(AppTheme.radiusSm)
        : BorderRadius.only(
            topLeft: const Radius.circular(AppTheme.radiusSm),
            topRight: const Radius.circular(AppTheme.radiusSm),
            // Imperfect corners
            bottomLeft: Radius.circular(AppTheme.radiusSm * 0.9),
            bottomRight: Radius.circular(AppTheme.radiusSm * 1.2),
          );
          
    final bool isDisabled = isLoading || onPressed == null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 52,
      decoration: BoxDecoration(
        // Handle disabled state visuals
        gradient: isPrimary && !isDisabled
            ? const LinearGradient(
                colors: [AppColors.deepPurple, Color(0xFF4A1248)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isDisabled 
               ? AppColors.lightPurple // Disabled state color from Design System
               : (isPrimary ? null : AppColors.white),
        borderRadius: borderRadius,
        boxShadow: isPrimary && !isDisabled ? AppTheme.buttonShadow : null,
        border: isPrimary || isDisabled
            ? null
            : Border.all(
                color: AppColors.deepPurple,
                width: 2,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Disable tap if loading or if onPressed is null
          onTap: isDisabled ? null : onPressed,
          borderRadius: borderRadius,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? AppColors.white : AppColors.deepPurple,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: AppTypography.textBase.copyWith(
                      color: isPrimary ? AppColors.white : (isDisabled ? AppColors.neutral500 : AppColors.deepPurple),
                      fontWeight: AppTypography.semibold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

#### lib/features/auth/presentation/widgets/social_auth_button.dart
```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final String iconAsset;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialAuthButton({
    Key? key,
    required this.text,
    required this.iconAsset,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.deepPurple,
                      ),
                    ),
                  )
                else ...[
                  Image.asset(
                    iconAsset,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Text(
                    text,
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral950,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### lib/features/auth/presentation/widgets/auth_text_field.dart (Modified)
```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  // Removed controller and validator, added onChanged and errorText
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool autofocus;

  const AuthTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.onChanged,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  // Use FocusNode for better focus management
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.textSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: AppTypography.medium,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            // Design System Adherence: Input field background color
            color: _isFocused
                ? AppColors.white
                : AppColors.white.withOpacity(0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusSm),
              topRight: Radius.circular(AppTheme.radiusSm),
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.deepPurple.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            autofocus: widget.autofocus,
            style: AppTypography.textBase.copyWith(
              color: AppColors.neutral950,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.textBase.copyWith(
                color: AppColors.neutral400,
              ),
              // Added errorText display
              errorText: widget.errorText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space4,
                vertical: AppTheme.space3,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.neutral300,
                  width: 2,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.neutral300,
                  width: 2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.deepPurple,
                  width: 2,
                ),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.coralRed,
                  width: 2,
                ),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.neutral500,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
```

### 2.5 Authentication Screens (Refactored)

#### lib/features/auth/presentation/screens/auth_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:formz/formz.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
// We use the LoginCubit here to handle the loading state and errors for OAuth flows.
import '../cubits/login/login_cubit.dart';
import '../cubits/login/login_state.dart';
import '../widgets/social_auth_button.dart';
import '../../data/repositories/auth_repository.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide LoginCubit to handle OAuth attempts from this screen
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: const AuthView(),
    );
  }
}

class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
       // Design System Adherence: Placeholder for texture overlay ("Digital with Soul")
      body: Container(
        /* decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/textures/noise-texture.png"),
            repeat: ImageRepeat.repeat,
            opacity: 0.05,
          ),
        ), */
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            // Navigation is handled centrally by GoRouter based on AuthBloc.
            // We only listen here for specific errors during the social login attempt.
            if (state.status.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.coralRed,
                  ),
                );
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        'M',
                        style: AppTypography.display3xl.copyWith(
                          color: AppColors.white,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),
                  // Welcome headline
                  Text(
                    'Welcome to Micasa',
                    style: AppTypography.display2xl.copyWith(
                      color: AppColors.deepPurple,
                      fontWeight: AppTypography.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.space3),
                  Text(
                    'Create, collaborate, and celebrate events',
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.space7),
                  // Auth buttons
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      // Use the Cubit's status to show loading indicator for OAuth
                      final isLoading = state.status.isInProgress;
                      
                      return Column(
                        children: [
                          SocialAuthButton(
                            text: 'Continue with Google',
                            iconAsset: 'assets/icons/google.png',
                            isLoading: isLoading,
                            onPressed: () {
                              context.read<LoginCubit>().logInWithGoogle();
                            },
                          ),
                          const SizedBox(height: AppTheme.space4),
                          SocialAuthButton(
                            text: 'Continue with Apple',
                            iconAsset: 'assets/icons/apple.png',
                            isLoading: isLoading,
                            onPressed: () {
                              context.read<LoginCubit>().logInWithApple();
                            },
                          ),
                          const SizedBox(height: AppTheme.space5),
                          // Divider with OR
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.neutral200,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space4,
                                ),
                                child: Text(
                                  'OR',
                                  style: AppTypography.textSm.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.neutral200,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.space5),
                          // Email option
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.go('/auth/email');
                                  },
                            child: Text(
                              'Continue with Email',
                              style: AppTypography.textBase.copyWith(
                                color: AppColors.deepPurple,
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### lib/features/auth/presentation/screens/email_auth_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:formz/formz.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/auth_repository.dart';
import '../cubits/login/login_cubit.dart';
import '../cubits/login/login_state.dart';
import '../cubits/signup/signup_cubit.dart';
import '../cubits/signup/signup_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class EmailAuthScreen extends StatelessWidget {
  const EmailAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide both Cubits to the view hierarchy
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(context.read<AuthRepository>()),
        ),
        BlocProvider(
          create: (context) => SignUpCubit(context.read<AuthRepository>()),
        ),
      ],
      child: const EmailAuthView(),
    );
  }
}

class EmailAuthView extends StatefulWidget {
  const EmailAuthView({Key? key}) : super(key: key);

  @override
  State<EmailAuthView> createState() => _EmailAuthViewState();
}

// Removed all local state management (TextEditingControllers, FormKeys, _acceptedTerms)
class _EmailAuthViewState extends State<EmailAuthView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral950),
          onPressed: () => context.pop(), 
        ),
      ),
      // Use MultiBlocListener to listen for submission errors from both Cubits
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state.status.isFailure && state.errorMessage != null) {
                _showError(context, state.errorMessage!);
              }
            },
          ),
          BlocListener<SignUpCubit, SignUpState>(
            listener: (context, state) {
              if (state.status.isFailure && state.errorMessage != null) {
                 _showError(context, state.errorMessage!);
              }
            },
          ),
        ],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
            child: Column(
              children: [
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.deepPurple,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.neutral600,
                    labelStyle: AppTypography.textBase.copyWith(
                      fontWeight: AppTypography.semibold,
                    ),
                    tabs: const [
                      Tab(text: 'Sign Up'),
                      Tab(text: 'Log In'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space6),
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _SignUpForm(),
                      _LoginForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.coralRed,
        ),
      );
  }
}

// Extracted Forms and Inputs for cleaner state management

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SignUpEmailInput(),
          const SizedBox(height: AppTheme.space5),
          _SignUpPasswordInput(),
          const SizedBox(height: AppTheme.space5),
          _TermsCheckbox(),
          const SizedBox(height: AppTheme.space6),
          _SignUpButton(),
        ],
      ),
    );
  }
}

// Implementations of _SignUpEmailInput, _SignUpPasswordInput, _TermsCheckbox, _SignUpButton
// Example: _SignUpEmailInput
class _SignUpEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return AuthTextField(
          label: 'Email',
          hint: 'Enter your email',
          onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          errorText: state.email.isNotValid && state.email.value.isNotEmpty ? 'Invalid email' : null,
        );
      },
    );
  }
}

class _SignUpPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return AuthTextField(
          label: 'Password',
          hint: 'Create a password',
          onChanged: (password) => context.read<SignUpCubit>().passwordChanged(password),
          isPassword: true,
          errorText: state.password.isNotValid && state.password.value.isNotEmpty
              ? 'Password must be at least 8 characters'
              : null,
        );
      },
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.termsAcceptance != current.termsAcceptance,
      builder: (context, state) {
        return Row(
          children: [
            Checkbox(
              value: state.termsAcceptance.value,
              onChanged: (value) {
                context.read<SignUpCubit>().termsAcceptanceChanged(value ?? false);
              },
              activeColor: AppColors.deepPurple,
            ),
            Expanded(
              child: Text(
                'I accept the Terms & Conditions',
                style: AppTypography.textSm.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        final isValid = Formz.validate([state.email, state.password, state.termsAcceptance]);
        return AuthButton(
          text: 'Create Account',
          isLoading: state.status.isInProgress,
          onPressed: isValid && !state.status.isInProgress
              ? () => context.read<SignUpCubit>().signUpFormSubmitted()
              : null,
        );
      },
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LoginEmailInput(),
          const SizedBox(height: AppTheme.space5),
          _LoginPasswordInput(),
          const SizedBox(height: AppTheme.space3),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to forgot password
              },
              child: Text(
                'Forgot Password?',
                style: AppTypography.textSm.copyWith(
                  color: AppColors.deepPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          _LoginButton(),
        ],
      ),
    );
  }
}

// Implementations of _LoginEmailInput, _LoginPasswordInput, _LoginButton
class _LoginEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return AuthTextField(
          label: 'Email / Username',
          hint: 'Enter your email or username',
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          errorText: state.email.isNotValid && state.email.value.isNotEmpty ? 'Invalid email' : null,
        );
      },
    );
  }
}

class _LoginPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return AuthTextField(
          label: 'Password',
          hint: 'Enter your password',
          onChanged: (password) => context.read<LoginCubit>().passwordChanged(password),
          isPassword: true,
          errorText: state.password.isNotValid && state.password.value.isNotEmpty
              ? 'Password is required'
              : null,
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isValid = Formz.validate([state.email, state.password]);
        return AuthButton(
          text: 'Log In',
          isLoading: state.status.isInProgress,
          // Enable button only if form is valid and not already submitting
          onPressed: isValid && !state.status.isInProgress
              ? () => context.read<LoginCubit>().logInWithCredentials()
              : null,
        );
      },
    );
  }
}
```

### 2.6 Supporting Files

#### lib/core/utils/validators.dart
(This utility file is now superseded by Formz models and can be removed.)

#### lib/router/app_router.dart (Refactored for Centralized Auth Logic)
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/email_auth_screen.dart';
// Placeholder screens (Assuming these will be implemented)
import '../features/dashboard/presentation/screens/dashboard_screen.dart'; 
import '../features/profile/presentation/screens/profile_setup_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    // Start at dashboard; redirect will handle initial routing based on auth state.
    initialLocation: '/dashboard', 
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: 'email',
            builder: (context, state) => const EmailAuthScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        // Screen 25: Mandatory Profile Initialization Gate
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
    ],
    // Centralized redirection logic listening to AuthBloc
    redirect: _redirectLogic,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
  );

  FutureOr<String?> _redirectLogic(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final loggingIn = state.matchedLocation.startsWith('/auth');
    final settingUpProfile = state.matchedLocation == '/profile-setup';

    // 1. Wait until the authentication status is determined
    if (authState.status == AuthStatus.unknown) {
      return null; // Stay on current route (e.g., splash/loading)
    }

    // 2. Handle Unauthenticated users
    if (authState.status == AuthStatus.unauthenticated) {
      // Allow access to auth routes, otherwise redirect to /auth
      return loggingIn ? null : '/auth';
    }

    // 3. Handle Authenticated users
    if (authState.status == AuthStatus.authenticated) {
      final user = authState.user!;
      
      // Check Screen 25 Gate: Mandatory Profile Initialization (Applies to OAuth and Email)
      if (user.requiresInitialization) {
        // Force redirection to profile setup if initialization is required
        return settingUpProfile ? null : '/profile-setup';
      }
      
      // If authenticated and initialized, redirect away from auth/setup screens
      if (loggingIn || settingUpProfile) return '/dashboard';
    }

    // In all other cases, allow the requested route
    return null;
  }
}

// Helper class to adapt BLoC stream to Listenable required by GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// --- Placeholder Screens for routing demonstration ---
// (These would be implemented in their respective feature folders)

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // SL7 compliance: The Dashboard (Screen 4) is the destination. Redirection handles the gate.
    return const Scaffold(body: Center(child: Text('Dashboard (Screen 4)')));
  }
}

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mandatory Profile Setup (Screen 25)'),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement profile update logic (PUT /users/me)
                // This should update the user data in the repository, which triggers an AuthBloc update, 
                // causing GoRouter to automatically redirect to the dashboard.
              },
              child: const Text('Complete Setup (Mock)'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### lib/main.dart (Modified for new dependencies and architecture)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/services/auth_api_service.dart';
import 'features/auth/data/services/token_storage_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize dependencies (Dependency Injection)
  const secureStorage = FlutterSecureStorage();
  final tokenStorageService = TokenStorageService(secureStorage);
  
  final dio = Dio();
  // Initialize ApiClient with Dio and TokenStorage
  final apiClient = ApiClient(dio, tokenStorageService);
  final authApiService = AuthApiService(apiClient);
  
  // Initialize the repository which manages the auth stream
  final authRepository = AuthRepository(
    authApiService: authApiService,
    tokenStorageService: tokenStorageService,
  );
  
  runApp(MicasaApp(authRepository: authRepository));
}

class MicasaApp extends StatefulWidget {
  final AuthRepository authRepository;
  
  const MicasaApp({
    Key? key,
    required this.authRepository,
  }) : super(key: key);

  @override
  State<MicasaApp> createState() => _MicasaAppState();
}

class _MicasaAppState extends State<MicasaApp> {
  late final AuthBloc authBloc;
  late final AppRouter appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize the global AuthBloc
    authBloc = AuthBloc(authRepository: widget.authRepository);
    // Initialize the router, passing the AuthBloc for centralized redirection
    appRouter = AppRouter(authBloc);
  }

  @override
  Widget build(BuildContext context) {
    // Provide the repository and the global AuthBloc to the app
    return RepositoryProvider.value(
      value: widget.authRepository,
      child: BlocProvider.value(
        value: authBloc,
        child: MaterialApp.router(
          title: 'Micasa',
          theme: AppTheme.lightTheme,
          routerConfig: appRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }

  @override
  void dispose() {
    authBloc.close();
    widget.authRepository.dispose();
    super.dispose();
  }
}
```

#### pubspec.yaml (Dependencies to add/update)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  bloc_concurrency: ^0.2.2 # Added for potential use in BLoCs
  
  # Navigation
  go_router: ^13.0.0
  
  # Networking (Replaced http with dio)
  dio: ^5.4.0 
  
  # Storage & Security (Replaced shared_preferences)
  flutter_secure_storage: ^9.0.0 
  
  # Functional Programming & Error Handling
  dartz: ^0.10.1 
  
  # Forms and Validation
  formz: ^0.7.0

  # Configuration Management
  flutter_dotenv: ^5.1.0

  # Fonts
  google_fonts: ^6.1.0
  
  # Authentication
  google_sign_in: ^6.1.5
  sign_in_with_apple: ^5.0.0
  
  # Utils
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 3. Assets Required

Create the following directories and add placeholder images:
```
assets/
├── icons/
│   ├── google.png
│   └── apple.png
└── images/
    └── logo.png
```

Update `pubspec.yaml` to include assets:
```yaml
flutter:
  assets:
    - assets/icons/
    - assets/images/
```

## 4. BLoC Pattern Architecture Explanation

The authentication flow uses a refined BLoC (Business Logic Component) pattern with enhanced separation of concerns:

### Separation of Concerns:
1. **Presentation Layer** (`screens/` and `widgets/`)
   - Contains UI components that react to state changes
   - Dispatches events to BLoCs/Cubits
   - Uses `BlocBuilder` and `BlocListener` for reactive UI
   - Form widgets directly connect to Cubits for real-time validation

2. **Business Logic Layer** 
   - **Global State (BLoC)**: `AuthBloc` manages the application-wide authentication session
   - **Screen State (Cubits)**: `LoginCubit` and `SignUpCubit` manage form-specific states
   - **Form Validation**: Formz models provide type-safe, reusable validation logic
   - Handles all business logic and state transitions

3. **Data Layer** (`data/`)
   - `AuthApiService`: Handles API communication via centralized Dio client
   - `TokenStorageService`: Manages secure token persistence
   - `AuthRepository`: Provides reactive authentication stream and error handling
   - `ApiClient`: Centralized HTTP client with interceptors for auth and errors

### Data Flow:
1. User interaction triggers Cubit methods (e.g., `emailChanged`, `logInWithCredentials`)
2. Cubit validates input using Formz and emits loading state
3. Cubit calls repository method with Either<Failure, Success> return
4. Repository delegates to services and handles errors
5. On success, repository updates auth stream
6. AuthBloc receives stream update and emits new global state
7. GoRouter's redirect logic responds to AuthBloc state changes
8. UI rebuilds based on both Cubit (local) and BLoC (global) states

### Key Improvements:
- **Security**: JWT tokens stored in encrypted storage (Keychain/Keystore)
- **Reactive Auth**: Authentication treated as a stream for instant updates
- **Granular State**: Form state separated from session state
- **Structured Errors**: Either type for explicit error handling
- **Centralized Navigation**: GoRouter handles all auth-based routing
- **Type-safe Validation**: Formz provides reusable, testable validation
- **API Resilience**: Dio interceptors handle auth headers and error parsing

## 5. Next Steps

After implementing the authentication flow:
1. Add asset files for Google and Apple icons
2. Configure OAuth providers (Google Sign-In and Sign in with Apple)
3. Set up backend API endpoints with proper error responses
4. Implement the Dashboard screen (Screen 4) with automatic modal display
5. Implement the Profile Setup screen (Screen 25/26) with proper API integration
6. Add token refresh interceptor for handling expired tokens
7. Implement "Digital with Soul" design elements (textures, hand-drawn accents)
8. Write unit tests for BLoCs, Cubits, and repository methods
9. Add integration tests for the complete auth flow
10. Configure environment-specific builds (dev, staging, prod)

This implementation strictly follows the Micasa Design System with:
- Deep purple primary colors with gradient treatments
- Card-based layouts with subtle shadows
- Custom text fields with animated focus states
- Consistent spacing using the defined scale
- Mobile-first responsive design
- Foundation for "imperfect, personality-driven" UI elements