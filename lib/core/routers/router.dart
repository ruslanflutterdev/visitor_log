import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/admin/screens/admin_audit_logs_screen.dart';
import '../../features/admin/screens/admin_coach_details_screen.dart';
import '../../features/admin/screens/admin_coaches_screen.dart';
import '../../features/admin/screens/admin_statistics_screen.dart';
import '../../features/admin/screens/admin_students_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/update_password_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/recovery_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/students/screens/group_details_screen.dart';
import '../../features/students/screens/incoming_transfers_screen.dart';
import '../utils/go_router_refresh_stream.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
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

    if (session != null && isAuthScreen && loc != '/update-password') {
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
        final isRecovery = state.uri.queryParameters['recovery'] == 'true';
        return OtpScreen(email: email, isRecovery: isRecovery);
      },
    ),
    GoRoute(
      path: '/update-password',
      builder: (BuildContext context, GoRouterState state) {
        return const UpdatePasswordScreen();
      },
    ),
    GoRoute(
      path: '/group/:id',
      builder: (BuildContext context, GoRouterState state) {
        final groupId = state.pathParameters['id']!;
        final groupName = state.extra as String? ?? 'Группа';
        return GroupDetailsScreen(groupId: groupId, groupName: groupName);
      },
    ),
    GoRoute(
      path: '/incoming-transfers',
      builder: (BuildContext context, GoRouterState state) =>
          const IncomingTransfersScreen(),
    ),
    GoRoute(
      path: '/admin/coaches',
      builder: (context, state) => const AdminCoachesScreen(),
    ),
    GoRoute(
      path: '/admin/students',
      builder: (context, state) => const AdminStudentsScreen(),
    ),
    GoRoute(
      path: '/admin/statistics',
      builder: (context, state) => const AdminStatisticsScreen(),
    ),
    GoRoute(
      path: '/admin/audit-logs',
      builder: (context, state) => const AdminAuditLogsScreen(),
    ),
    GoRoute(
      path: '/admin/coach/:id',
      builder: (context, state) {
        final coach = state.extra as Map;
        return AdminCoachDetailsScreen(coach: coach);
      },
    ),
  ],
);
