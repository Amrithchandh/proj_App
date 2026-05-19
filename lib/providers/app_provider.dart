import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  UserProfile? _profile;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  AppProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    
    _profile = await _storageService.loadProfile();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    await _storageService.saveProfile(newProfile);
    _profile = newProfile;
    notifyListeners();
  }

  Future<void> clearProfile() async {
    await _storageService.clearProfile();
    _profile = null;
    notifyListeners();
  }
}
