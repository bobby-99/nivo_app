// Updated tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nivo_app/models/task.dart';
import 'package:nivo_app/providers/task_provider.dart';
import 'package:nivo_app/screens/tasks/create_task_modal.dart';
import 'package:nivo_app/widgets/task_tile.dart';
import 'package:nivo_app/widgets/app_bar.dart';
import 'package:nivo_app/utils/constants.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    // Tab controller for category tabs
    _tabController = TabController(
      length: AppConstants.defaultCategories.length, 
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = AppConstants.defaultCategories[_tabController.index];
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTaskModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tasks',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
              indicatorColor: theme.colorScheme.primary,
              tabs: AppConstants.defaultCategories.map((category) {
                return Tab(text: category);
              }).toList(),
            ),
          ),
          
          // Task list
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                // Filter tasks by selected category
                final List<Task> filteredTasks = _selectedCategory == 'All'
                    ? taskProvider.tasks
                    : taskProvider.getTasksByCategory(_selectedCategory);
                
                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: theme.colorScheme.onBackground.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a new task',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return TaskTile(
                      task: task,
                      onToggleCompletion: () {
                        taskProvider.toggleTaskCompletion(task.id);
                      },
                      onDelete: () {
                        taskProvider.deleteTask(task.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskModal,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}