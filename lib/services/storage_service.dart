import '../models/routine.dart';
import '../models/user_profile.dart';
import 'database_helper.dart';

class StorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> saveRoutines(List<Routine> routines) async {
    await _dbHelper.saveRoutines(routines);
  }

  Future<List<Routine>> loadRoutines() async {
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
    await _dbHelper.saveProfile(profile);
  }

  Future<UserProfile?> loadProfile() async {
    return await _dbHelper.getProfile();
  }

  Future<void> clearProfile() async {
    await _dbHelper.deleteProfile();
    await _dbHelper.clearRoutines();
  }
}
