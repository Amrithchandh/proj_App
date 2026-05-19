import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

// Settings screen for managing user profile and preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();
  
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscurePassword = true; // Visibility toggle for email password

  // Controllers for editable fields
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String _selectedGender = 'Male';
  String _selectedAvatarKey = 'student_boy';

  // Built-in list of beautiful avatars with emojis and gradients
  final Map<String, Map<String, dynamic>> _avatars = {
    'student_boy': {'emoji': '👦', 'label': 'Student (Boy)', 'color': Colors.blue},
    'student_girl': {'emoji': '👧', 'label': 'Student (Girl)', 'color': Colors.pink},
    'workout': {'emoji': '🏋️', 'label': 'Gym Student', 'color': Colors.orange},
    'study': {'emoji': '📚', 'label': 'Bookworm', 'color': Colors.purple},
    'gamer': {'emoji': '🎮', 'label': 'Gamer', 'color': Colors.teal},
    'anime': {'emoji': '📺', 'label': 'Otaku', 'color': Colors.red},
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    if (_profile != null) {
      _usernameController.dispose();
      _emailController.dispose();
      _passwordController.dispose();
    }
    super.dispose();
  }

  // Load the current profile details from SharedPreferences
  Future<void> _loadProfileData() async {
    final loadedProfile = await _storageService.loadProfile();
    if (loadedProfile != null) {
      setState(() {
        _profile = loadedProfile;
        _usernameController = TextEditingController(text: loadedProfile.username);
        _emailController = TextEditingController(text: loadedProfile.email);
        _passwordController = TextEditingController(text: loadedProfile.password);
        _selectedGender = loadedProfile.gender;
        _selectedAvatarKey = loadedProfile.avatarKey;
        _isLoading = false;
      });
    } else {
      // Fallback in case profile loads incorrectly (e.g. redirect back to login)
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save the updated profile inputs back to persistent local storage
  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final updatedProfile = UserProfile(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      gender: _selectedGender,
      password: _passwordController.text.trim(),
      avatarKey: _selectedAvatarKey,
    );

    await _storageService.saveProfile(updatedProfile);

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    // Pop the screen and return true to indicate changes were made (forces refresh on Home)
    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: const Color(0xFFFFE600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Clear profile and log out, redirecting straight back to LoginScreen
  Future<void> _handleLogout() async {
    // Show a confirm dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out? This will reset your profile and habits list.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LOG OUT', style: TextStyle(color: Color(0xFFFFE600))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.clearProfile();
      if (!mounted) return;
      // Push and remove all routes until we reach the LoginScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Open Avatar Picker modal bottom sheet to select standard icons or input Web URL
  void _openAvatarPicker() {
    final urlController = TextEditingController(
      text: _selectedAvatarKey.startsWith('http') ? _selectedAvatarKey : '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Choose Profile Photo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Avatar Grid Selection
                  const Text("Built-in Avatars", style: TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _avatars.length,
                    itemBuilder: (context, index) {
                      final key = _avatars.keys.elementAt(index);
                      final data = _avatars[key]!;
                      final isSelected = _selectedAvatarKey == key;

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedAvatarKey = key;
                            urlController.clear();
                          });
                          setState(() {
                            _selectedAvatarKey = key;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFE600).withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFE600) : Colors.white.withValues(alpha: 0.06),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data['emoji'], style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 4),
                              Text(
                                data['label'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Custom Image URL Input
                  const Text("Or Add Custom Image URL", style: TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "https://example.com/photo.jpg",
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF0F0F12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFFFE600)),
                      ),
                    ),
                    onChanged: (val) {
                      if (val.trim().isNotEmpty) {
                        setModalState(() {
                          _selectedAvatarKey = val.trim();
                        });
                        setState(() {
                          _selectedAvatarKey = val.trim();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Close bottom sheet button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE600),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Renders the Avatar circle based on key or URL
  Widget _buildAvatarWidget(double size) {
    if (_selectedAvatarKey.startsWith('http')) {
      return CircleAvatar(
        radius: size,
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        backgroundImage: NetworkImage(_selectedAvatarKey),
        // Error builder handles invalid/broken URLs gracefully so we "never show error"
        child: ClipOval(
          child: Image.network(
            _selectedAvatarKey,
            width: size * 2,
            height: size * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 28),
            ),
          ),
        ),
      );
    }

    final avatarData = _avatars[_selectedAvatarKey] ?? _avatars['student_boy']!;
    final Color color = avatarData['color'];

    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFFFE600).withValues(alpha: 0.2), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        avatarData['emoji'],
        style: TextStyle(fontSize: size * 1.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F0F12);
    const Color yellowAccent = Color(0xFFFFE600);
    const Color cardColor = Color(0xFF1E1E24);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('Settings & Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: yellowAccent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. INTERACTIVE AVATAR PICKER
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: _openAvatarPicker,
                              child: _buildAvatarWidget(50),
                            ),
                            GestureDetector(
                              onTap: _openAvatarPicker,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: yellowAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Tap to edit profile photo",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // 2. INPUT FIELDS
                      // Username Field
                      const Text(
                        "Username",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Username",
                          filled: true,
                          fillColor: cardColor,
                          prefixIcon: const Icon(Icons.person_outline, color: yellowAccent, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter a username';
                          if (value.trim().length < 3) return 'Username must be at least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Mail ID Field
                      const Text(
                        "Mail ID",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Mail ID",
                          filled: true,
                          fillColor: cardColor,
                          prefixIcon: const Icon(Icons.email_outlined, color: yellowAccent, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter an email';
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(value.trim())) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Gender Selection Dropdown
                      const Text(
                        "Gender",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: cardColor,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardColor,
                          prefixIcon: const Icon(Icons.people_outline, color: yellowAccent, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedGender = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password of Mail Field
                      const Text(
                        "Password of Mail",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter password",
                          filled: true,
                          fillColor: cardColor,
                          prefixIcon: const Icon(Icons.lock_outline, color: yellowAccent, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white38,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter a password';
                          if (value.trim().length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 48),

                      // 3. ACTION BUTTONS
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfileChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellowAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Text(
                                "Save Profile Changes",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton(
                        onPressed: _handleLogout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Log Out",
                          style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
