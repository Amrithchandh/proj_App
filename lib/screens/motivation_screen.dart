import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  List<Map<String, String>> _quotesList = [];
  int _currentQuoteIndex = 0;
  bool _isLoading = true;

  // Mock categories for the Wrap widget
  final List<String> _categories = [
    'Focus', 'Discipline', 'Success', 'Hard Work', 'Positivity', 'Growth'
  ];

  // Robust list of default/fallback motivational quotes
  final List<Map<String, String>> _defaultQuotes = [
    {
      'q': 'The only way to do great work is to love what you do.',
      'a': 'Steve Jobs'
    },
    {
      'q': 'Believe you can and you\'re halfway there.',
      'a': 'Theodore Roosevelt'
    },
    {
      'q': 'It always seems impossible until it\'s done.',
      'a': 'Nelson Mandela'
    },
    {
      'q': 'Don\'t watch the clock; do what it does. Keep going.',
      'a': 'Sam Levenson'
    },
    {
      'q': 'Act as if what you do makes a difference. It does.',
      'a': 'William James'
    },
    {
      'q': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'a': 'Winston Churchill'
    },
    {
      'q': 'You are never too old to set another goal or to dream a new dream.',
      'a': 'C.S. Lewis'
    },
    {
      'q': 'Start where you are. Use what you have. Do what you can.',
      'a': 'Arthur Ashe'
    },
    {
      'q': 'Opportunities don\'t happen. You create them.',
      'a': 'Chris Grosser'
    },
    {
      'q': 'Your limit—it\'s just your imagination.',
      'a': 'Unknown'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate with default local quotes
    _quotesList = List.from(_defaultQuotes);
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Free public API returning a list of 50 random quotes
      final response = await http.get(Uri.parse('https://zenquotes.io/api/quotes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final List<Map<String, String>> fetched = data.map((item) {
            return {
              'q': item['q']?.toString() ?? '',
              'a': item['a']?.toString() ?? '',
            };
          }).toList();
          setState(() {
            _quotesList = fetched;
            _currentQuoteIndex = 0;
            _isLoading = false;
          });
        } else {
          throw Exception('Empty quote response');
        }
      } else {
        throw Exception('Failed to load quotes');
      }
    } catch (e) {
      print('Quote fetch error, using local fallback quotes: $e');
      setState(() {
        _quotesList = List.from(_defaultQuotes);
        _currentQuoteIndex = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color yellowAccent = Color(0xFFFFE600);
    const Color cardColor = Color(0xFF1E1E24);

    final String quoteText = _quotesList.isNotEmpty ? _quotesList[_currentQuoteIndex]['q']! : '';
    final String quoteAuthor = _quotesList.isNotEmpty ? _quotesList[_currentQuoteIndex]['a']! : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivation Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: yellowAccent),
            tooltip: 'Reload quotes from web',
            onPressed: _fetchQuotes,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                constraints: const BoxConstraints(minHeight: 180),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: yellowAccent.withValues(alpha: 0.3), width: 1),
                ),
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: yellowAccent))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.format_quote, color: yellowAccent, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          '"$quoteText"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '- $quoteAuthor',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: yellowAccent,
                          ),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 16),
              
              // Quote carousel navigation row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentQuoteIndex > 0
                        ? () {
                            setState(() {
                              _currentQuoteIndex--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: yellowAccent,
                      disabledForegroundColor: Colors.white24,
                      disabledBackgroundColor: cardColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _currentQuoteIndex > 0 ? yellowAccent.withValues(alpha: 0.3) : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  Text(
                    '${_currentQuoteIndex + 1} / ${_quotesList.length}',
                    style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  ElevatedButton.icon(
                    onPressed: _quotesList.isNotEmpty
                        ? () {
                            setState(() {
                              if (_currentQuoteIndex < _quotesList.length - 1) {
                                _currentQuoteIndex++;
                              } else {
                                _currentQuoteIndex = 0; // wrap around
                              }
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: yellowAccent,
                      disabledForegroundColor: Colors.white24,
                      disabledBackgroundColor: cardColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _quotesList.isNotEmpty ? yellowAccent.withValues(alpha: 0.3) : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
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
      ),
    );
  }
}
