import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/email_auth_screen.dart';
import '../features/navigation/presentation/screens/main_app_shell.dart';
// Placeholder screens (Assuming these will be implemented)
import '../features/dashboard/presentation/screens/dashboard_screen.dart'; 
import '../features/profile/presentation/screens/profile_setup_screen.dart';
import '../features/events/presentation/screens/my_events_screen.dart';
import '../features/events/presentation/screens/event_creation_step1_screen.dart';
import '../features/events/presentation/screens/event_creation_step2_screen.dart';
import '../features/events/presentation/screens/event_management_screen.dart';
import '../features/events/presentation/cubits/event_creation_step1/event_creation_step1_state.dart';
import '../features/community/presentation/screens/my_community_screen.dart';
import '../features/profile/presentation/screens/profile_hub_screen.dart';
import '../features/collaboration/presentation/screens/event_collaboration_hub_screen.dart';
import '../features/collaboration/presentation/screens/create_edit_position_screen.dart';
import '../features/collaboration/presentation/screens/applicant_list_screen.dart';
import '../features/collaboration/data/models/position_models.dart';

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
        // Screen 25: Mandatory Profile Initialization Gate
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainAppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/my-events',
            builder: (context, state) => const MyEventsScreen(),
          ),
          GoRoute(
            path: '/my-community',
            builder: (context, state) => const MyCommunityScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileHubScreen(),
          ),
        ],
      ),
      // Event creation routes (outside of shell for full-screen experience)
      GoRoute(
        path: '/event/create',
        builder: (context, state) => const EventCreationStep1Screen(),
      ),
      GoRoute(
        path: '/event/create/step2',
        builder: (context, state) {
          final step1Data = state.extra as EventCreationStep1State?;
          if (step1Data == null) {
            // If no step1 data, redirect back to step 1
            return const EventCreationStep1Screen();
          }
          return EventCreationStep2Screen(step1Data: step1Data);
        },
      ),
      GoRoute(
        path: '/event/manage/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventManagementScreen(eventId: eventId);
        },
      ),
      // Collaboration management routes
      GoRoute(
        path: '/collaboration/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventCollaborationHubScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/collaboration/:eventId/position/create',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return CreateEditPositionScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/collaboration/:eventId/position/:positionId/edit',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final position = state.extra as OpenPosition?;
          return CreateEditPositionScreen(
            eventId: eventId,
            editPosition: position,
          );
        },
      ),
      GoRoute(
        path: '/collaboration/applicants/:positionId',
        builder: (context, state) {
          final positionId = state.pathParameters['positionId']!;
          final positionTitle = state.extra as String? ?? 'Position';
          return ApplicantListScreen(
            positionId: positionId,
            positionTitle: positionTitle,
          );
        },
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

