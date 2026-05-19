import 'package:flutter/material.dart';
import '../models/routine.dart';

// This is the custom habit card widget. It is designed to match the dark-grey 
// rounded layout in the screenshot, complete with yellow highlight borders 
// on completion, streak badges, and category emojis.
class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;       // Action when card is tapped (toggles completion)
  final VoidCallback onDelete;   // Action when delete icon is pressed

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onDelete,
  });

  // Simple helper function to return the correct emoji based on the routine title or category
  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'workout':
        return '🏋️';
      case 'drink water':
        return '🥛';
      case 'attend class':
        return '🎓';
      case 'design assignment':
      case 'assignments':
        return '📝';
      case 'watch anime':
        return '📺';
      case 'study':
        return '📚';
      case 'reading':
        return '📖';
      case 'sleep':
        return '🛌';
      default:
        return '📋'; // Default sheet icon for custom tasks
    }
  }

  @override
  Widget build(BuildContext context) {
    final String emoji = _getCategoryEmoji(routine.category);
    final bool isCompleted = routine.isCompleted;

    return GestureDetector(
      onTap: onTap, // Tapping the card triggers the completion toggle
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // Smooth border transition animation
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24), // Medium dark-grey card background
          borderRadius: BorderRadius.circular(16), // Rounded cards
          // Border is bright yellow when completed, and a very subtle dark grey when incomplete
          border: Border.all(
            color: isCompleted ? const Color(0xFFFFE600) : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
          boxShadow: [
            if (isCompleted)
              BoxShadow(
                color: const Color(0xFFFFE600).withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          children: [
            // LEFT SIDE: Habit Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Emoji Row
                  Row(
                    children: [
                      Text(
                        routine.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          // Optional: Draw a line-through if completed, 
                          // but the screenshot keeps text plain white. Let's keep it elegant.
                          decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          decorationColor: const Color(0xFFFFE600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Time Subtitle (e.g., "6 AM to 8 PM")
                  Text(
                    routine.time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5), // Semi-transparent white
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Flame Streak Indicator Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🔥',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${routine.streak}-day streak',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // RIGHT SIDE: Frequency, Delete Button, and Completed Timestamp
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Frequency text (top right of the card)
                Text(
                  routine.frequency,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Trash icon button to delete habit
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.white.withOpacity(0.35),
                    size: 20,
                  ),
                  onPressed: onDelete,
                ),
                const SizedBox(height: 12),
                
                // Completed Time Timestamp (bottom right of the card - only shows if completed)
                if (isCompleted && routine.completedTime != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Small completed status dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE600), // Yellow dot
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        routine.completedTime!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  // Empty space placeholder to keep vertical alignment consistent
                  const SizedBox(height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
