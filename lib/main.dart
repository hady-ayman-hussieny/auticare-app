import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auticare/core/theme/theme.dart';
import 'package:auticare/core/router/app_router.dart';
import 'package:auticare/features/auth/logic/auth_provider.dart';
import 'package:auticare/features/parent/logic/child_provider.dart';
import 'package:auticare/features/notifications/notification_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutiCareApp());
}

class AutiCareApp extends StatelessWidget {
  const AutiCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return MaterialApp.router(
      title: 'AutiCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: buildRouter(auth),
    );
  }
}
