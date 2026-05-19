import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';
import 'models/user_profile.dart';
import 'providers/app_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const RoutineTrackerApp(),
    ),
  );
}

class RoutineTrackerApp extends StatelessWidget {
  const RoutineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBgColor = Color(0xFF0F0F12);
    const Color yellowColor = Color(0xFFFFE600);
    const Color cardColor = Color(0xFF1E1E24);

    return MaterialApp(
      title: 'Routine Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBgColor,
        primaryColor: yellowColor,
        colorScheme: const ColorScheme.dark(
          primary: yellowColor,
          secondary: yellowColor,
          surface: cardColor,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBgColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return yellowColor;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      home: FutureBuilder<UserProfile?>(
        future: StorageService().loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F0F12),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFE600)),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
