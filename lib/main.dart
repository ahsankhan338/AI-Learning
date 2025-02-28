import 'package:aieducator/provider/auth_provider.dart';
import 'package:aieducator/router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  AppRouter(authProvider);

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const EduApp(),
    ),
  );
}

class EduApp extends StatelessWidget {
  const EduApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(Provider.of<AuthProvider>(context));

    return MaterialApp.router(
      title: "AI Learner",
      routerConfig: appRouter.router,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFD9D9D9)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'ai_learner',
    );
  }
}
