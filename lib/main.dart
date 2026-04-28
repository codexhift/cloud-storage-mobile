import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/splash_view.dart';
import 'features/main/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file");
  }

  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );


  runApp(const ProviderScope(child: MyApp()));

}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Cloud Storage',
      theme: AppTheme.lightTheme,

      home: authState.when(
        data: (user) {
          if (user == null) {
            return const LoginView();
          }
          return const MainView(); 
        },
        error: (err, stack) => const LoginView(), // fallback to login on error
        loading: () => const SplashView(),
      ),

      debugShowCheckedModeBanner: false,
      home: authState.isLoading
          ? const SplashView()
          : authState.isAuthenticated
          ? const MainView()
          : const LoginView(),

    );
  }
}
