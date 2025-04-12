// Updated custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:nivo_app/theme/palette.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Palette.darkBackground
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.repeat,
            label: 'Habits',
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.task_alt,
            label: 'Tasks',
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.timer,
            label: 'Timer',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width / 3,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 3,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onBackground.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}