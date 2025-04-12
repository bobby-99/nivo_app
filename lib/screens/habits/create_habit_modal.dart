import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivo_app/models/habit.dart';
import 'package:nivo_app/providers/habit_provider.dart';
import 'package:uuid/uuid.dart';


class CreateHabitModal extends ConsumerStatefulWidget {
  final Habit? editHabit;
  const CreateHabitModal({super.key, this.editHabit});

  @override
  ConsumerState<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends ConsumerState<CreateHabitModal> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    _controller.forward();
    
    // Auto-focus title field after animation starts
    Future.delayed(const Duration(milliseconds: 150), () {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.editHabit != null ? 'Edit Habit' : 'Create Habit',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ScaleTransition(
                    scale: _opacityAnimation,
                    child: TextFormField(
                      focusNode: _titleFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Habit Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a habit name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      focusNode: _descriptionFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: ElevatedButton(
                      onPressed: _submitHabit,
                      child: Text(widget.editHabit != null ? 'Update Habit' : 'Create Habit'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitHabit() {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: widget.editHabit?.id ?? const Uuid().v4(),
        title: 'New Habit', // Replace with actual form values
        startDate: DateTime.now(),
        frequency: HabitFrequency.daily,
      );

      if (widget.editHabit != null) {
        ref.read(habitProvider.notifier).updateHabit(habit.id, habit);
      } else {
        ref.read(habitProvider.notifier).addHabit(habit);
      }
      Navigator.pop(context);
    }
  }
}