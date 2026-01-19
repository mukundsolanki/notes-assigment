import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/task_entity.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final String? label;

  const PriorityBadge({super.key, required this.priority, this.label});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label ?? config.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: config.color,
        ),
      ),
    );
  }

  _PriorityConfig _getConfig(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return _PriorityConfig(color: AppColors.priorityHigh, label: 'High');
      case TaskPriority.medium:
        return _PriorityConfig(color: AppColors.priorityMedium, label: 'Medium');
      case TaskPriority.low:
        return _PriorityConfig(color: AppColors.priorityLow, label: 'Low');
    }
  }
}

class _PriorityConfig {
  final Color color;
  final String label;

  _PriorityConfig({required this.color, required this.label});
}
