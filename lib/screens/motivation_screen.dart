import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  String _quote = 'Loading quote...';
  String _author = '';
  bool _isLoading = true;

  // Mock categories for the Wrap widget
  final List<String> _categories = [
    'Focus', 'Discipline', 'Success', 'Hard Work', 'Positivity', 'Growth'
  ];

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Free public API for random quotes
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = data[0]['q'];
          _author = data[0]['a'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      setState(() {
        _quote = 'Keep pushing forward. You are doing great!';
        _author = 'System';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color yellowAccent = Color(0xFFFFE600);
    const Color cardColor = Color(0xFF1E1E24);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivation API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: yellowAccent),
            onPressed: _fetchQuote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quote of the Day',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: yellowAccent.withValues(alpha: 0.3), width: 1),
              ),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: yellowAccent))
                : Column(
                    children: [
                      const Icon(Icons.format_quote, color: yellowAccent, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        '"$_quote"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '- $_author',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: yellowAccent,
                        ),
                      ),
                    ],
                  ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Topics (Using Wrap Widget)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0, // Gap between adjacent chips
              runSpacing: 12.0, // Gap between lines
              children: _categories.map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
