import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';
import '../widgets/options_bottom_sheet.dart';
import 'add_edit_task_screen.dart';
import 'calendar_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    // Trigger filtering by adding a SearchTasks event
    context.read<TaskBloc>().add(SearchTasks(query: _searchQuery));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.backgroundGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showOptionsMenu(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Today, ${DateFormat('d MMM').format(DateTime.now())}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'My tasks',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint.withValues(alpha: 0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 8, right: 12),
                          child: Icon(
                            Icons.search,
                            color: AppColors.primaryPurple,
                            size: 22,
                          ),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.textHint.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.clear,
                                      color: AppColors.textHint.withValues(alpha: 0.8),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryPurple,
                      ),
                    );
                  }

                  if (state is TaskError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  if (state is TaskLoaded) {
                    final tasks = state.filteredTasks;

                    if (tasks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Icon(
                                  _searchQuery.isEmpty 
                                      ? Icons.task_alt_outlined
                                      : Icons.search_off,
                                  size: 60,
                                  color: AppColors.primaryPurple.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _searchQuery.isEmpty 
                                    ? 'No tasks yet'
                                    : 'No tasks found',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Create your first task to get started!'
                                    : 'Try adjusting your search terms or filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textHint.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Group tasks by date
                    final groupedTasks = _groupTasksByDate(tasks);

                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        ...groupedTasks.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  entry.key.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              // Tasks
                              ...entry.value.map((task) {
                                return TaskCard(
                                  task: task,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEditTaskScreen(task: task),
                                      ),
                                    );
                                  },
                                );
                              }),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.list, color: AppColors.primaryPurple),
                onPressed: () {},
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryPurple,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CalendarScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<TaskGroup, List<TaskEntity>> _groupTasksByDate(List<TaskEntity> tasks) {
    final Map<TaskGroup, List<TaskEntity>> grouped = {};

    for (final task in tasks) {
      final group = DateHelper.getTaskGroup(task.dueDate);
      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(task);
    }

    return grouped;
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const OptionsBottomSheet(),
    );
  }
}