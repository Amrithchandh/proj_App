import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../models/user_profile.dart';
import 'database_helper.dart';

class StorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Storage keys for Web Persistence
  static const String _webRoutinesKey = 'web_routines_db';
  static const String _webProfileKey = 'web_profile_db';

  Future<void> saveRoutines(List<Routine> routines) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = routines
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await prefs.setStringList(_webRoutinesKey, list);
      print('=== Web Database: Saved ${routines.length} routines persistently ===');
      return;
    }
    await _dbHelper.saveRoutines(routines);
  }

  Future<List<Routine>> loadRoutines() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? list = prefs.getStringList(_webRoutinesKey);

      if (list == null) {
        final defaultList = [
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
          ),
          Routine(
            title: 'Design Assignment',
            time: '7 PM to 9 PM',
            category: 'Design Assignment',
            frequency: '2 day a week',
            streak: 5,
            isCompleted: false,
          ),
          Routine(
            title: 'Watch Anime',
            time: 'All day',
            category: 'Watch Anime',
            frequency: 'Daily',
            streak: 2,
            isCompleted: false,
          ),
        ];
        await saveRoutines(defaultList);
        return defaultList;
      }

      return list
          .map((item) => Routine.fromJson(jsonDecode(item)))
          .toList();
    }

    final list = await _dbHelper.getRoutines();
    
    if (list.isEmpty) {
      final defaultList = [
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
        ),
        Routine(
          title: 'Design Assignment',
          time: '7 PM to 9 PM',
          category: 'Design Assignment',
          frequency: '2 day a week',
          streak: 5,
          isCompleted: false,
        ),
        Routine(
          title: 'Watch Anime',
          time: 'All day',
          category: 'Watch Anime',
          frequency: 'Daily',
          streak: 2,
          isCompleted: false,
        ),
      ];
      await saveRoutines(defaultList);
      return defaultList;
    }

    return list;
  }

  Future<void> saveProfile(UserProfile profile) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(profile.toJson());
      await prefs.setString(_webProfileKey, jsonStr);
      print('=== Web Database: Saved profile for "${profile.username}" persistently ===');
      return;
    }
    await _dbHelper.saveProfile(profile);
  }

  Future<UserProfile?> loadProfile() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_webProfileKey);
      if (jsonStr == null) return null;
      return UserProfile.fromJson(jsonDecode(jsonStr));
    }
    return await _dbHelper.getProfile();
  }

  Future<void> clearProfile() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webProfileKey);
      await prefs.remove(_webRoutinesKey);
      print('=== Web Database: Cleared persistent database ===');
      return;
    }
    await _dbHelper.deleteProfile();
    await _dbHelper.clearRoutines();
  }
}
