class UserProfile {
  String username;
  String email;
  String gender;
  String password;
  String avatarKey;

  UserProfile({
    required this.username,
    required this.email,
    required this.gender,
    required this.password,
    required this.avatarKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'gender': gender,
      'password': password,
      'avatarKey': avatarKey,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? 'Male',
      password: json['password'] ?? '',
      avatarKey: json['avatarKey'] ?? 'student_boy',
    );
  }
}
