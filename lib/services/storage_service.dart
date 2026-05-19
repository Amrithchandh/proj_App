import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/routine.dart';
import '../models/user_profile.dart';
import 'database_helper.dart';

class StorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // In-memory fallback database for Web Browsers (Chrome/Edge)
  static UserProfile? _webProfileCache;
  static List<Routine>? _webRoutinesCache;

  Future<void> saveRoutines(List<Routine> routines) async {
    if (kIsWeb) {
      _webRoutinesCache = List.from(routines);
      print('=== Web Persistence: Saved ${routines.length} routines in memory ===');
      return;
    }
    await _dbHelper.saveRoutines(routines);
  }

  Future<List<Routine>> loadRoutines() async {
    if (kIsWeb) {
      if (_webRoutinesCache == null) {
        _webRoutinesCache = [
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
      }
      return _webRoutinesCache!;
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
      _webProfileCache = profile;
      print('=== Web Persistence: Saved profile for "${profile.username}" ===');
      return;
    }
    await _dbHelper.saveProfile(profile);
  }

  Future<UserProfile?> loadProfile() async {
    if (kIsWeb) {
      return _webProfileCache;
    }
    return await _dbHelper.getProfile();
  }

  Future<void> clearProfile() async {
    if (kIsWeb) {
      _webProfileCache = null;
      _webRoutinesCache = null;
      print('=== Web Persistence: Cleared memory cache ===');
      return;
    }
    await _dbHelper.deleteProfile();
    await _dbHelper.clearRoutines();
  }
}
