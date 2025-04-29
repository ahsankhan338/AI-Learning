import 'package:aieducator/provider/auth_provider.dart';
import 'package:aieducator/provider/routes_refresh_notifier.dart';
import 'package:aieducator/router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthProvider authProvider = AuthProvider();
  final RoutesRefreshNotifier refreshNotifier = RoutesRefreshNotifier();
  final appRouter = AppRouter(authProvider, refreshNotifier);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: refreshNotifier),
      ],
      child: EduApp(appRouter: appRouter),
    ),
  );
}

class EduApp extends StatelessWidget {
  final AppRouter appRouter;

  const EduApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "AI Learner",
      routerConfig: appRouter.router,
      theme: ThemeData(
        fontFamily: "Poppins",
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          //========================================================
          titleLarge: TextStyle(
            color: Colors.white,
          ),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          //========================================================
          labelLarge: TextStyle(
            color: Colors.white,
          ),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFD9D9D9),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'ai_learner',
    );
  }
}
