import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_log/core/routers/router.dart';
import 'package:visitor_log/features/auth/bloc/auth_bloc.dart';
import 'package:visitor_log/features/auth/bloc/auth_event.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

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
    return BlocProvider(
      create: (context) => AuthBloc()..add(AuthInitialize()),
      child: MaterialApp.router(
        title: 'Visitor Log',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}