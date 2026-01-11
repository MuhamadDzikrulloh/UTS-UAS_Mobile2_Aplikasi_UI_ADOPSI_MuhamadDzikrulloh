import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/onboarding.dart';
import 'screens/home.dart';
import 'screens/detail.dart';
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  GoogleFonts.config.allowRuntimeFetching = true;
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: const ColorScheme.light().copyWith(primary: Colors.teal),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
    );


    return MaterialApp(
      title: 'Pet Adoption',
      theme: theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/detail': (ctx) => const PetDetailPage(),
      },
    );
  }
}
