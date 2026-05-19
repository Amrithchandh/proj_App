import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // Import LoginScreen
import 'services/storage_service.dart'; // Import StorageService
import 'models/user_profile.dart'; // Import UserProfile

void main() {
  // Ensure that Flutter widget binding is fully initialized.
  // This is a great student-level best practice when doing asynchronous actions 
  // like loading local storage data during startup.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoutineTrackerApp());
}

// This is the root widget of the entire application.
// It sets up the MaterialApp configurations, sets the deep-dark visual theme, 
// disables the debug banner, and loads our main HomeScreen dashboard as the entry.
class RoutineTrackerApp extends StatelessWidget {
  const RoutineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the custom dark-theme colors matching the screenshot design
    const Color darkBgColor = Color(0xFF0F0F12);
    const Color yellowColor = Color(0xFFFFE600);
    const Color cardColor = Color(0xFF1E1E24);

    return MaterialApp(
      title: 'Routine Tracker',
      debugShowCheckedModeBanner: false, // Hides the red "debug" ribbon in the top right
      themeMode: ThemeMode.dark, // Always run in dark mode
      
      // Highly cohesive dark theme design with yellow accent colors
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBgColor,
        primaryColor: yellowColor,
        
        // Define color scheme for widgets to inherit automatically
        colorScheme: const ColorScheme.dark(
          primary: yellowColor,
          secondary: yellowColor,
          surface: cardColor,
          background: darkBgColor,
        ),
        
        // Customize text themes to look modern and sharp
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        
        // Style AppBars globally across the application
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
        
        // Style standard check boxes to match gold-yellow colors
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return yellowColor; // Solid yellow when checked
            }
            return Colors.transparent; // Transparent otherwise
          }),
          checkColor: MaterialStateProperty.all(Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      
      // Launch dynamically: check if user is logged in, else route to LoginScreen
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
