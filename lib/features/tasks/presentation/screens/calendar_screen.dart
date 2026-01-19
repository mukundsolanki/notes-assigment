import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _focusedDate;
  Map<DateTime, List<TaskEntity>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<TaskBloc>().add(LoadTasks(userId: authState.user.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            );
          }

          if (state is TaskError) {
            return Center(
              child: Text(
                'Error loading tasks',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          if (state is TaskLoaded) {
            _tasksByDate = _groupTasksByDate(state.tasks);
            return Column(
              children: [
                // Calendar Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.backgroundGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _focusedDate = DateTime(
                              _focusedDate.year,
                              _focusedDate.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _focusedDate = DateTime(
                              _focusedDate.year,
                              _focusedDate.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                // Calendar Grid
                Expanded(
                  child: _buildCalendarGrid(),
                ),
                
                // Selected Date Tasks
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildTasksForSelectedDate(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final day = index - startingWeekday + 1;
        final isCurrentMonth = day > 0 && day <= daysInMonth;
        final date = isCurrentMonth 
            ? DateTime(_focusedDate.year, _focusedDate.month, day)
            : null;
            
        final isSelected = date != null && 
            date.day == _selectedDate.day &&
            date.month == _selectedDate.month &&
            date.year == _selectedDate.year;
            
        final hasTasks = date != null && _tasksByDate.containsKey(
            DateTime(date.year, date.month, date.day)
        );

        return GestureDetector(
          onTap: () {
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primaryPurple 
                  : hasTasks 
                      ? AppColors.primaryPurple.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isCurrentMonth 
                  ? Border.all(color: AppColors.textHint.withValues(alpha: 0.3))
                  : null,
            ),
            child: Center(
              child: Text(
                isCurrentMonth ? '$day' : '',
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : hasTasks 
                          ? AppColors.primaryPurple
                          : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksForSelectedDate() {
    final selectedDateKey = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final tasks = _tasksByDate[selectedDateKey] ?? [];

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks for this date',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            // Navigate to task edit
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(task: task),
              ),
            );
          },
        );
      },
    );
  }

  Map<DateTime, List<TaskEntity>> _groupTasksByDate(List<TaskEntity> tasks) {
    final Map<DateTime, List<TaskEntity>> grouped = {};

    for (final task in tasks) {
      final date = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(task);
    }

    return grouped;
  }
}
