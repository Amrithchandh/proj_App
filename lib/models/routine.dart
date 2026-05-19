class Routine {
  int? id;
  String title;
  String time;
  String category;
  String frequency;
  int streak;
  bool isCompleted;
  String? completedTime;

  Routine({
    this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.frequency,
    this.streak = 0,
    this.isCompleted = false,
    this.completedTime,
  });

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
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as int?,
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
