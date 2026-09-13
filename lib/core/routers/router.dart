import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/groups/groups_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final Session? session = Supabase.instance.client.auth.currentSession;
    final bool isLoggingIn = state.matchedLocation == '/';

    if (session == null && !isLoggingIn) {
      return '/';
    }

    if (session != null && isLoggingIn) {
      return '/groups';
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
      path: '/groups',
      builder: (BuildContext context, GoRouterState state) {
        return const GroupsScreen();
      },
    ),
  ],
);