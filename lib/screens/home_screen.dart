import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/routine.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../widgets/arc_progress_painter.dart';
import '../widgets/routine_card.dart';
import 'add_routine_screen.dart';
import 'settings_screen.dart'; 
import 'motivation_screen.dart'; // Import motivation screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Routine> _routines = [];
  bool _isLoadingRoutines = true;
  int _selectedIndex = 0; // BottomNavigationBar index

  final Map<String, String> _avatarEmojis = {
    'student_boy': '👦',
    'student_girl': '👧',
    'workout': '🏋️',
    'study': '📚',
    'gamer': '🎮',
    'anime': '📺',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final loadedList = await _storageService.loadRoutines();
      // Profile is now loaded via AppProvider!
      setState(() {
        _routines = loadedList;
        _isLoadingRoutines = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRoutines = false;
      });
    }
  }

  Future<void> _saveData() async {
    await _storageService.saveRoutines(_routines);
  }

  void _toggleRoutineCompletion(int index) {
    setState(() {
      final routine = _routines[index];
      if (routine.isCompleted) {
        routine.isCompleted = false;
        routine.completedTime = null;
        if (routine.streak > 0) routine.streak -= 1; 
      } else {
        routine.isCompleted = true;
        routine.completedTime = TimeOfDay.now().format(context);
        routine.streak += 1; 
      }
    });

    _saveData(); 

    final routineName = _routines[index].title;
    final statusText = _routines[index].isCompleted ? 'Completed' : 'Reset to incomplete';
    final streakText = _routines[index].isCompleted ? '🔥 Streak +1!' : '';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$routineName marked as $statusText! $streakText'),
        backgroundColor: const Color(0xFFFFE600), 
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.black,
          onPressed: () {},
        ),
      ),
    );
  }

  void _deleteRoutine(int index) {
    final deletedName = _routines[index].title;
    setState(() {
      _routines.removeAt(index);
    });
    _saveData();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Routine "$deletedName" was deleted.'),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _navigateAndAddRoutine() async {
    final Routine? newRoutine = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRoutineScreen()),
    );

    if (!mounted) return;

    if (newRoutine != null) {
      setState(() {
        _routines.add(newRoutine);
      });
      _saveData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newRoutine.title}" added to your habits!'),
          backgroundColor: const Color(0xFFFFE600),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _navigateToSettings(AppProvider provider) async {
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    if (updated == true) {
      // Reload profile globally via Provider
      provider.loadProfile();
    }
  }

  Widget _buildHeaderAvatar(AppProvider provider) {
    const double size = 20.0;
    const Color yellowAccent = Color(0xFFFFE600);

    if (provider.isLoading || provider.profile == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
      );
    }

    final avatarKey = provider.profile!.avatarKey;

    if (avatarKey.startsWith('http')) {
      return CircleAvatar(
        radius: size,
        backgroundColor: Colors.white10,
        backgroundImage: NetworkImage(avatarKey),
        child: ClipOval(
          child: Image.network(
            avatarKey,
            width: size * 2,
            height: size * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.person, color: Colors.white30, size: 16),
            ),
          ),
        ),
      );
    }

    if (avatarKey.startsWith('data:image/')) {
      final base64Data = avatarKey.split(',').last;
      final bytes = base64Decode(base64Data);
      return CircleAvatar(
        radius: size,
        backgroundImage: MemoryImage(bytes),
      );
    }

    final String emoji = _avatarEmojis[avatarKey] ?? '👦';

    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1E24),
        border: Border.all(color: yellowAccent.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: yellowAccent.withValues(alpha: 0.15),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }

  List<DateTime> _getCenteredWeek() {
    final today = DateTime.now();
    return List.generate(7, (index) => today.subtract(Duration(days: 3 - index)));
  }

  String _getDayNameAbbr(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Widget _buildDashboard() {
    const Color darkBg = Color(0xFF0F0F12);
    const Color yellowAccent = Color(0xFFFFE600);
    
    // Accessing state through Provider
    final appProvider = Provider.of<AppProvider>(context);

    int totalCount = _routines.length;
    int completedCount = _routines.where((r) => r.isCompleted).length;
    double progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    int progressPercent = (progress * 100).toInt();

    final weekDays = _getCenteredWeek();
    final today = DateTime.now();

    return _isLoadingRoutines
        ? const Center(child: CircularProgressIndicator(color: yellowAccent))
        : SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appProvider.profile != null ? "Hi, ${appProvider.profile!.username}!" : "Today's Track",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToSettings(appProvider),
                        child: _buildHeaderAvatar(appProvider),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 120,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: CustomPaint(
                          painter: ArcProgressPainter(progress: progress),
                        ),
                      ),
                      Positioned(
                        top: 25,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_upward, color: yellowAccent, size: 18),
                            const SizedBox(height: 2),
                            Text(
                              '$progressPercent %',
                              style: const TextStyle(color: yellowAccent, fontSize: 26, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'completed',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: weekDays.map((day) {
                      final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getDayNameAbbr(day.weekday),
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.3),
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              border: isToday ? const Border(bottom: BorderSide(color: yellowAccent, width: 2)) : null,
                            ),
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isToday ? yellowAccent : Colors.white,
                                fontSize: 14,
                                fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _routines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                                const SizedBox(height: 16),
                                const Text('Your tracker is empty!', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('Tap "+ Add new Routine" to populate habits.', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _routines.length,
                            itemBuilder: (context, index) {
                              return RoutineCard(
                                routine: _routines[index],
                                onTap: () => _toggleRoutineCompletion(index),
                                onDelete: () => _deleteRoutine(index),
                              );
                            },
                          ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: darkBg,
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  child: SafeArea(
                    top: false,
                    child: TextButton(
                      onPressed: _navigateAndAddRoutine,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, color: yellowAccent, size: 20),
                          SizedBox(width: 4),
                          Text('Add new Routine', style: TextStyle(color: yellowAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F0F12);
    const Color cardColor = Color(0xFF1E1E24);
    const Color yellowAccent = Color(0xFFFFE600);

    return Scaffold(
      backgroundColor: darkBg,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const MotivationScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        selectedItemColor: yellowAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Motivation',
          ),
        ],
      ),
    );
  }
}
