import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../models/user_profile.dart'; // Import user profile model

// This service is responsible for persisting the routine data on the device.
// It uses the shared_preferences package to store and retrieve data as a List of Strings.
class StorageService {
  // Key to identify our routines list in SharedPreferences
  static const String _storageKey = 'student_routines_list';
  
  // Key to identify our user profile in SharedPreferences
  static const String _profileKey = 'student_user_profile';

  // Save the list of routines to SharedPreferences
  Future<void> saveRoutines(List<Routine> routines) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Map each Routine object to its JSON representation (Map) and then to a String.
    // List<Routine> -> List<Map<String, dynamic>> -> List<String>
    List<String> routineStrings = routines
        .map((routine) => jsonEncode(routine.toJson()))
        .toList();
        
    await prefs.setStringList(_storageKey, routineStrings);
  }

  // Load the list of routines from SharedPreferences
  Future<List<Routine>> loadRoutines() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? routineStrings = prefs.getStringList(_storageKey);

    // If no routines are saved (first time opening the app), we load the exact 
    // default habits from the user's screenshot!
    if (routineStrings == null) {
      return [
        Routine(
          title: 'Workout',
          time: '6 AM to 8 PM',
          category: 'Workout',
          frequency: '3 day a week',
          streak: 9,
          isCompleted: true,
          completedTime: '5:15 AM',
        ),
        Routine(
          title: 'Drink Water',
          time: 'All day',
          category: 'Drink Water',
          frequency: 'Daily',
          streak: 12,
          isCompleted: true,
          completedTime: '12:00 PM',
        ),
        Routine(
          title: 'Attend Class',
          time: '11 AM to 5 PM',
          category: 'Attend Class',
          frequency: '1 day a week',
          streak: 3,
          isCompleted: false,
          completedTime: null,
        ),
        Routine(
          title: 'Design Assignment',
          time: '7 PM to 9 PM',
          category: 'Design Assignment',
          frequency: '2 day a week',
          streak: 5,
          isCompleted: false,
          completedTime: null,
        ),
        Routine(
          title: 'Watch Anime',
          time: 'All day',
          category: 'Watch Anime',
          frequency: 'Daily',
          streak: 2,
          isCompleted: false,
          completedTime: null,
        ),
      ];
    }

    // Convert the List of JSON Strings back to a List of Routine objects
    // List<String> -> List<Map<String, dynamic>> -> List<Routine>
    return routineStrings
        .map((routineStr) => Routine.fromJson(jsonDecode(routineStr)))
        .toList();
  }

  // Save the UserProfile to local SharedPreferences
  Future<void> saveProfile(UserProfile profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  // Load the UserProfile from local SharedPreferences
  Future<UserProfile?> loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profileJson = prefs.getString(_profileKey);
    if (profileJson == null || profileJson.isEmpty) {
      return null; // Return null if user is not logged in / no profile found
    }
    return UserProfile.fromJson(jsonDecode(profileJson));
  }

  // Clear UserProfile details (logout capability)
  Future<void> clearProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    // Optionally also clear routines to simulate a fresh environment for the next user login
    await prefs.remove(_storageKey);
  }
}
