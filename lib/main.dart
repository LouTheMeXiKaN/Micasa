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