import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivo_app/providers/task_provider.dart';
import 'package:nivo_app/screens/tasks/create_task_modal.dart';
import 'package:nivo_app/widgets/app_bar.dart';
import 'package:nivo_app/widgets/task_tile.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All Tasks';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabController();
    });
  }

  void _updateTabController() {
    final categories = ref.read(taskProvider.notifier).categories;
    _tabController = TabController(
      length: categories.length,
      vsync: this,
      initialIndex: categories.indexOf(_selectedCategory),
    );
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final categories = ref.read(taskProvider.notifier).categories;
      setState(() {
        _selectedCategory = categories[_tabController.index];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final categories = ref.read(taskProvider.notifier).categories;
    final filteredTasks = ref.read(taskProvider.notifier).getTasksByCategory(_selectedCategory);

    // Update tab controller when categories change
    if (_tabController.length != categories.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTabController();
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tasks',
        bottom: TabBar( // Remove PreferredSize wrapper
          controller: _tabController,
          isScrollable: true,
          tabs: [...],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: categories.map((category) => Tab(text: category)).toList(),
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final categoryTasks = ref.read(taskProvider.notifier).getTasksByCategory(category);
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: categoryTasks.length,
            itemBuilder: (context, index) {
              final task = categoryTasks[index];
              return TaskTile(
                task: task,
                onToggleComplete: (isCompleted) {
                  ref.read(taskProvider.notifier).toggleComplete(task.id);
                },
                onDelete: () {
                  ref.read(taskProvider.notifier).deleteTask(task.id);
                },
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return const CreateTaskModal();
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}