// This class represents a single Routine (or Habit) in our application.
// It is designed to hold all the necessary properties of a routine
// and includes helper methods to convert it to and from JSON (Map) 
// so we can easily store it in SharedPreferences.
class Routine {
  String title;         // Name of the routine (e.g., "Workout")
  String time;          // Time range or slot (e.g., "6 AM to 8 PM")
  String category;      // Category of task (e.g., "Workout", "Drink Water")
  String frequency;     // How often to do it (e.g., "Daily", "3 day a week")
  int streak;           // Flame streak counter (e.g., 9)
  bool isCompleted;     // Whether the routine is completed for today
  String? completedTime; // The exact time it was completed (e.g., "5:15 AM")

  // Simple Constructor to initialize a Routine object
  Routine({
    required this.title,
    required this.time,
    required this.category,
    required this.frequency,
    this.streak = 0,
    this.isCompleted = false,
    this.completedTime,
  });

  // Convert a Routine object into a Map (JSON representation)
  // This is used when we want to save our routines to SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time,
      'category': category,
      'frequency': frequency,
      'streak': streak,
      'isCompleted': isCompleted,
      'completedTime': completedTime,
    };
  }

  // Create a Routine object from a Map (JSON representation)
  // This is used when we load our routines back from SharedPreferences.
  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      category: json['category'] ?? '',
      frequency: json['frequency'] ?? '',
      streak: json['streak'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedTime: json['completedTime'],
    );
  }
}
