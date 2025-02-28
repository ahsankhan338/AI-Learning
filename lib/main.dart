import 'package:aieducator/provider/auth_provider.dart';
import 'package:aieducator/router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final appRouter = AppRouter(authProvider);

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
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
