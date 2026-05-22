import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/routine.dart';
import '../models/user_profile.dart';
import 'database_helper.dart';

class StorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Storage keys for Web Persistence
  static const String _webRoutinesKey = 'web_routines_db';
  static const String _webProfileKey = 'web_profile_db';

  // Get the dynamic API base URL based on platform
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the special IP mapping to host's localhost in Android emulator
      return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // Health check ping to detect if the backend Node.js server is online
  Future<bool> _isBackendOnline() async {
    try {
      final response = await http
          .get(Uri.parse('$_backendUrl/health'))
          .timeout(const Duration(milliseconds: 1000));
      return response.statusCode == 200;
    } catch (e) {
      print('Backend check failed (Server is offline): $e');
      return false;
    }
  }

  // ----------------------------------------------------
  // Routines Storage Logic
  // ----------------------------------------------------

  Future<void> saveRoutines(List<Routine> routines) async {
    // 1. Always save locally first for instant UI response and offline support
    await _saveRoutinesLocally(routines);

    // 2. Try to save to backend NoSQL database if online
    if (await _isBackendOnline()) {
      try {
        final response = await http.post(
          Uri.parse('$_backendUrl/routines'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(routines.map((r) => r.toJson()).toList()),
        );
        if (response.statusCode == 200) {
          print('=== Backend Sync: Successfully saved routines to NoSQL DB ===');
        } else {
          print('=== Backend Sync Warning: Server returned status code ${response.statusCode} ===');
        }
      } catch (e) {
        print('=== Backend Sync Error: Failed to save to backend: $e ===');
      }
    }
  }

  Future<List<Routine>> loadRoutines() async {
    // 1. Check if backend is online
    if (await _isBackendOnline()) {
      try {
        final response = await http.get(Uri.parse('$_backendUrl/routines'));
        if (response.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(response.body);
          final routines = jsonList.map((item) => Routine.fromJson(item)).toList();
          
          // Sync/update local cache
          await _saveRoutinesLocally(routines);
          print('=== Backend Sync: Loaded ${routines.length} routines from NoSQL DB ===');
          return routines;
        }
      } catch (e) {
        print('=== Backend Sync Error: Failed to fetch routines: $e. Using local database. ===');
      }
    }

    // 2. Fallback to local storage
    return await _loadRoutinesLocally();
  }

  // ----------------------------------------------------
  // Profile Storage Logic
  // ----------------------------------------------------

  Future<void> saveProfile(UserProfile profile) async {
    // 1. Always save locally first
    await _saveProfileLocally(profile);

    // 2. Try to sync to backend NoSQL database
    await _saveProfileOnBackend(profile);
  }

  Future<void> _saveProfileOnBackend(UserProfile profile) async {
    if (await _isBackendOnline()) {
      try {
        final response = await http.post(
          Uri.parse('$_backendUrl/profile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(profile.toJson()),
        );
        if (response.statusCode == 200) {
          print('=== Backend Sync: Saved profile for "${profile.username}" persistently ===');
        }
      } catch (e) {
        print('=== Backend Sync Error: Failed to save profile to backend: $e ===');
      }
    }
  }

  Future<UserProfile?> loadProfile() async {
    // 1. Check if backend is online
    if (await _isBackendOnline()) {
      try {
        final response = await http.get(Uri.parse('$_backendUrl/profile'));
        if (response.statusCode == 200) {
          final profile = UserProfile.fromJson(jsonDecode(response.body));
          // Cache locally
          await _saveProfileLocally(profile);
          print('=== Backend Sync: Loaded profile for "${profile.username}" from NoSQL DB ===');
          return profile;
        } else if (response.statusCode == 404) {
          // Profile not found on backend. Check if we have it locally to upload.
          final localProfile = await _loadProfileLocally();
          if (localProfile != null) {
            await _saveProfileOnBackend(localProfile);
            return localProfile;
          }
        }
      } catch (e) {
        print('=== Backend Sync Error: Failed to fetch profile: $e. Using local database. ===');
      }
    }

    // 2. Fallback to local storage
    return await _loadProfileLocally();
  }

  Future<void> clearProfile() async {
    // 1. Clear locally
    await _clearLocally();

    // 2. Try to clear on backend NoSQL database
    if (await _isBackendOnline()) {
      try {
        final response = await http.delete(Uri.parse('$_backendUrl/profile'));
        if (response.statusCode == 200) {
          print('=== Backend Sync: Cleared backend database ===');
        }
      } catch (e) {
        print('=== Backend Sync Error: Failed to clear backend database: $e ===');
      }
    }
  }

  // ----------------------------------------------------
  // Private Helpers for Local Storage Persistence
  // ----------------------------------------------------

  Future<void> _saveRoutinesLocally(List<Routine> routines) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = routines
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await prefs.setStringList(_webRoutinesKey, list);
      return;
    }
    await _dbHelper.saveRoutines(routines);
  }

  Future<List<Routine>> _loadRoutinesLocally() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? list = prefs.getStringList(_webRoutinesKey);

      if (list == null) {
        final defaultList = _getDefaultRoutines();
        await _saveRoutinesLocally(defaultList);
        return defaultList;
      }

      return list
          .map((item) => Routine.fromJson(jsonDecode(item)))
          .toList();
    }

    final list = await _dbHelper.getRoutines();
    
    if (list.isEmpty) {
      final defaultList = _getDefaultRoutines();
      await _saveRoutinesLocally(defaultList);
      return defaultList;
    }

    return list;
  }

  Future<void> _saveProfileLocally(UserProfile profile) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(profile.toJson());
      await prefs.setString(_webProfileKey, jsonStr);
      return;
    }
    await _dbHelper.saveProfile(profile);
  }

  Future<UserProfile?> _loadProfileLocally() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_webProfileKey);
      if (jsonStr == null) return null;
      return UserProfile.fromJson(jsonDecode(jsonStr));
    }
    return await _dbHelper.getProfile();
  }

  Future<void> _clearLocally() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webProfileKey);
      await prefs.remove(_webRoutinesKey);
      return;
    }
    await _dbHelper.deleteProfile();
    await _dbHelper.clearRoutines();
  }

  List<Routine> _getDefaultRoutines() {
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
}

