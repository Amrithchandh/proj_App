import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
//famid
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final StorageService _storageService = StorageService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newProfile = UserProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        gender: 'Male',
        password: 'password123',
        avatarKey: 'student_boy',
      );

      await _storageService.saveProfile(newProfile);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F0F12);
    const Color yellowAccent = Color(0xFFFFE600);
    const Color inputFill = Color(0xFF1E1E24);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: inputFill,
                        shape: BoxShape.circle,
                        border: Border.all(color: yellowAccent.withValues(alpha: 0.15), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: yellowAccent.withValues(alpha: 0.05),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        color: yellowAccent,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Today's Track",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Build streaks, stay consistent, master your daily routines.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "What should we call you?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your username",
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      prefixIcon: const Icon(Icons.person_outline, color: yellowAccent, size: 20),
                      filled: true,
                      fillColor: inputFill,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: yellowAccent, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "What is your Email address?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "example@student.com",
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      prefixIcon: const Icon(Icons.email_outlined, color: yellowAccent, size: 20),
                      filled: true,
                      fillColor: inputFill,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: yellowAccent, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: yellowAccent.withValues(alpha: 0.25),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
