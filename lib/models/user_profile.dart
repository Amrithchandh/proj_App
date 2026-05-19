// This model represents the user's profile details.
// It keeps track of their login name, email address, gender, mail password, 
// and the chosen profile avatar key (or custom image URL).
class UserProfile {
  String username;
  String email;
  String gender;
  String password;
  String avatarKey; // Can hold an avatar asset name or a custom Web Image URL

  UserProfile({
    required this.username,
    required this.email,
    required this.gender,
    required this.password,
    required this.avatarKey,
  });

  // Convert a UserProfile object into a JSON Map to save in SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'gender': gender,
      'password': password,
      'avatarKey': avatarKey,
    };
  }

  // Instantiate a UserProfile object from a JSON Map loaded from SharedPreferences
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? 'Male',
      password: json['password'] ?? '',
      avatarKey: json['avatarKey'] ?? 'student_boy', // Default avatar key
    );
  }
}
