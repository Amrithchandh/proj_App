class Routine {
  int? id;
  String title;
  String time;
  String category;
  String frequency;
  int streak;
  bool isCompleted;
  String? completedTime;
  List<int> scheduledDays;
  String? specificDate;

  Routine({
    this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.frequency,
    this.streak = 0,
    this.isCompleted = false,
    this.completedTime,
    List<int>? scheduledDays,
    this.specificDate,
  }) : scheduledDays = scheduledDays ?? [1, 2, 3, 4, 5, 6, 7];

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'time': time,
      'category': category,
      'frequency': frequency,
      'streak': streak,
      'isCompleted': isCompleted,
      'completedTime': completedTime,
      'scheduledDays': scheduledDays.join(','),
      if (specificDate != null) 'specificDate': specificDate,
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    List<int> parseScheduledDays(dynamic value) {
      if (value == null) return [1, 2, 3, 4, 5, 6, 7];
      if (value is List) {
        return List<int>.from(value.map((e) => int.parse(e.toString())));
      }
      final str = value.toString();
      if (str.isEmpty) return [1, 2, 3, 4, 5, 6, 7];
      try {
        return str.split(',').map((e) => int.parse(e.trim())).toList();
      } catch (_) {
        return [1, 2, 3, 4, 5, 6, 7];
      }
    }

    return Routine(
      id: json['id'] as int?,
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      category: json['category'] ?? '',
      frequency: json['frequency'] ?? '',
      streak: json['streak'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedTime: json['completedTime'],
      scheduledDays: parseScheduledDays(json['scheduledDays']),
      specificDate: json['specificDate'],
    );
  }
}
