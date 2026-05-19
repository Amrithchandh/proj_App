import 'package:flutter_test/flutter_test.dart';
import 'package:ictak/models/routine.dart';
import 'package:ictak/models/user_profile.dart';

void main() {
  group('Model Tests', () {
    test('Routine toJson and fromJson serialization', () {
      final routine = Routine(
        id: 1,
        title: 'Exercise',
        time: '8 AM',
        category: 'Workout',
        frequency: 'Daily',
        streak: 3,
        isCompleted: true,
        completedTime: '8:05 AM',
      );

      final json = routine.toJson();
      expect(json['id'], 1);
      expect(json['title'], 'Exercise');
      expect(json['streak'], 3);
      expect(json['isCompleted'], true);

      final fromJson = Routine.fromJson(json);
      expect(fromJson.id, 1);
      expect(fromJson.title, 'Exercise');
      expect(fromJson.streak, 3);
      expect(fromJson.isCompleted, true);
    });

    test('UserProfile toJson and fromJson serialization', () {
      final profile = UserProfile(
        username: 'Amrith',
        email: 'amrith@example.com',
        gender: 'Male',
        password: 'password123',
        avatarKey: 'student_boy',
      );

      final json = profile.toJson();
      expect(json['username'], 'Amrith');
      expect(json['email'], 'amrith@example.com');

      final fromJson = UserProfile.fromJson(json);
      expect(fromJson.username, 'Amrith');
      expect(fromJson.email, 'amrith@example.com');
    });
  });
}
