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
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/data/services/profile_api_service.dart';
import 'features/events/data/repositories/event_repository.dart';
import 'features/events/data/services/event_api_service.dart';
import 'features/collaboration/data/repositories/collaboration_repository.dart';
import 'features/collaboration/data/services/collaboration_api_service.dart';
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
  
  // Initialize profile services
  final profileApiService = ProfileApiService(apiClient);
  final profileRepository = ProfileRepository(
    profileApiService: profileApiService,
    tokenStorageService: tokenStorageService,
    authRepository: authRepository,
  );
  
  // Initialize event services
  final eventApiService = EventApiService(apiClient);
  final eventRepository = EventRepository(
    eventApiService: eventApiService,
  );
  
  // Initialize collaboration services
  final collaborationApiService = CollaborationApiService(apiClient);
  final collaborationRepository = CollaborationRepository(
    apiService: collaborationApiService,
  );
  
  runApp(MicasaApp(
    authRepository: authRepository,
    profileRepository: profileRepository,
    eventRepository: eventRepository,
    collaborationRepository: collaborationRepository,
  ));
}

class MicasaApp extends StatefulWidget {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final EventRepository eventRepository;
  final CollaborationRepository collaborationRepository;
  
  const MicasaApp({
    Key? key,
    required this.authRepository,
    required this.profileRepository,
    required this.eventRepository,
    required this.collaborationRepository,
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
    // Provide the repositories and the global AuthBloc to the app
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.profileRepository),
        RepositoryProvider.value(value: widget.eventRepository),
        RepositoryProvider.value(value: widget.collaborationRepository),
      ],
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