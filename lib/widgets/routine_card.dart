import 'package:flutter/material.dart';
import '../models/routine.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    required this.onDelete,
  });

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
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String emoji = _getCategoryEmoji(routine.category);
    final bool isCompleted = routine.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? const Color(0xFFFFE600) : Colors.white.withValues(alpha: 0.06),
            width: 1.5,
          ),
          boxShadow: [
            if (isCompleted)
              BoxShadow(
                color: const Color(0xFFFFE600).withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        routine.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
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
                  Text(
                    routine.time,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  routine.frequency,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 20,
                  ),
                  onPressed: onDelete,
                ),
                const SizedBox(height: 12),
                if (isCompleted && routine.completedTime != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE600),
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
                  const SizedBox(height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
