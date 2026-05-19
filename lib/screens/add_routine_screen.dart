import 'package:flutter/material.dart';
import '../models/routine.dart';

// This screen allows students to add new routines to their daily schedule.
// It has form validation, category and frequency selectors, and an elegant
// double time-picker flow (Start Time and End Time) to format duration strings.
class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController(text: 'All day');
  
  bool _isAllDay = true; // State of the "All day" toggle
  String _selectedCategory = 'Workout'; // Default category
  String _selectedFrequency = 'Daily'; // Default frequency

  // Predefined student-focused categories matching screenshot and requirements
  final List<String> _categories = [
    'Workout',
    'Drink Water',
    'Attend Class',
    'Design Assignment',
    'Watch Anime',
    'Study',
    'Reading',
    'Sleep',
    'Custom tasks',
  ];

  // Frequency options matching screenshot
  final List<String> _frequencies = [
    'Daily',
    '1 day a week',
    '2 day a week',
    '3 day a week',
    '4 day a week',
    '5 day a week',
    '6 day a week',
  ];

  // Helper method to let user pick start and end times to format a range string
  Future<void> _pickTimeRange() async {
    // 1. Pick Start Time
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'SELECT START TIME',
    );

    if (startTime == null) return;

    if (!mounted) return;

    // 2. Pick End Time
    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      ),
      helpText: 'SELECT END TIME',
    );

    if (endTime == null) return;

    // 3. Format the range and update the state
    final String startFormatted = startTime.format(context);
    final String endFormatted = endTime.format(context);
    
    setState(() {
      _timeController.text = '$startFormatted to $endFormatted';
      _isAllDay = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deep dark background color to match the design system
    const Color darkBg = Color(0xFF0F0F12);
    const Color cardBg = Color(0xFF1E1E24);
    const Color yellowAccent = Color(0xFFFFE600);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text(
          'Add New Routine',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'What is your routine called?',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                
                // Routine Title Text Field
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g., Study Flutter, Workout',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: yellowAccent, width: 1),
                    ),
                    prefixIcon: const Icon(Icons.edit, color: Colors.white54),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a routine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'Select Category',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: cardBg,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.category_outlined, color: Colors.white54),
                  ),
                  items: _categories.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'Frequency',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                
                // Frequency Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  dropdownColor: cardBg,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.repeat, color: Colors.white54),
                  ),
                  items: _frequencies.map((String freq) {
                    return DropdownMenuItem<String>(
                      value: freq,
                      child: Text(freq),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFrequency = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'Routine Timing',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                
                // Time Range Input Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _timeController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          readOnly: true, // Only modifiable via timepicker or toggle
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      
                      // Text button to select time
                      TextButton(
                        onPressed: _pickTimeRange,
                        child: const Text(
                          'Pick Range',
                          style: TextStyle(color: yellowAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // All Day Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isAllDay,
                      activeColor: yellowAccent,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white30, width: 1.5),
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            _isAllDay = value;
                            if (_isAllDay) {
                              _timeController.text = 'All day';
                            } else {
                              _timeController.text = '8:00 AM to 9:00 AM'; // Default fallback
                            }
                          });
                        }
                      },
                    ),
                    const Text(
                      'This task takes all day (no specific time)',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Save and Cancel Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Create a new Routine model and return it
                            final newRoutine = Routine(
                              title: _titleController.text.trim(),
                              time: _timeController.text,
                              category: _selectedCategory,
                              frequency: _selectedFrequency,
                              streak: 0, // Starts at 0
                              isCompleted: false, // Starts as incomplete
                              completedTime: null,
                            );
                            
                            // Pop this screen and return the new object
                            Navigator.pop(context, newRoutine);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellowAccent,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Save Routine',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
