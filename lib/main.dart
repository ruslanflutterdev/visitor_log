import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_log/core/routers/router.dart';
import 'package:visitor_log/features/auth/bloc/auth_bloc.dart';
import 'package:visitor_log/features/auth/bloc/auth_event.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/session_timeout_manager.dart';
import 'features/groups/bloc/groups_bloc.dart';
import 'features/groups/bloc/groups_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://munhsuotwasnxxlkacaq.supabase.co',
    publishableKey: 'sb_publishable_nlN3t9hQtcBNnGGOd4aCDw_dt11pbG4',
  );
  runApp(const VisitorLogApp());
}

class VisitorLogApp extends StatelessWidget {
  const VisitorLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(AuthInitialize())),
        BlocProvider(create: (context) => GroupsBloc()..add(LoadGroups())),
      ],
      child: SessionTimeoutManager(
        timeoutDuration: const Duration(minutes: 30),
        child: MaterialApp.router(
          title: 'Visitor Log',
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
