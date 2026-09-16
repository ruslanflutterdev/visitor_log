import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/recovery_screen.dart';
import '../../features/auth/screens/otp_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final Session? session = Supabase.instance.client.auth.currentSession;
    final loc = state.matchedLocation;

    final bool isAuthScreen =
        loc == '/' ||
        loc == '/register' ||
        loc == '/recovery' ||
        loc.startsWith('/otp');

    if (session == null && !isAuthScreen) {
      return '/';
    }

    if (session != null && isAuthScreen) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthScreen();
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const DashboardScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/recovery',
      builder: (BuildContext context, GoRouterState state) {
        return const RecoveryScreen();
      },
    ),
    GoRoute(
      path: '/otp/:email',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.pathParameters['email']!;
        return OtpScreen(email: email);
      },
    ),
  ],
);
