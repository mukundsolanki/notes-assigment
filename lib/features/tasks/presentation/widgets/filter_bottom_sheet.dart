import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.textHint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textHint,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Filter Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildFilterOption(
                    icon: Icons.task_alt,
                    title: 'All Tasks',
                    subtitle: 'Show all tasks regardless of priority',
                    iconColor: AppColors.textSecondary,
                    onTap: () {
                      context.read<TaskBloc>().add(const FilterTasks());
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterOption(
                    icon: Icons.priority_high,
                    title: 'High Priority',
                    subtitle: 'Show only high priority tasks',
                    iconColor: AppColors.error,
                    onTap: () {
                      context.read<TaskBloc>().add(
                        const FilterTasks(priority: TaskPriority.high),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterOption(
                    icon: Icons.remove,
                    title: 'Medium Priority',
                    subtitle: 'Show only medium priority tasks',
                    iconColor: AppColors.warning,
                    onTap: () {
                      context.read<TaskBloc>().add(
                        const FilterTasks(priority: TaskPriority.medium),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterOption(
                    icon: Icons.keyboard_arrow_down,
                    title: 'Low Priority',
                    subtitle: 'Show only low priority tasks',
                    iconColor: AppColors.success,
                    onTap: () {
                      context.read<TaskBloc>().add(
                        const FilterTasks(priority: TaskPriority.low),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: iconColor.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
