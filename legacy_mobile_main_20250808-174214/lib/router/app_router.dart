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

