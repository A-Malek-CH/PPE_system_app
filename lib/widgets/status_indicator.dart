import 'package:flutter/material.dart';

/// Widget that displays the status of a PPE item (helmet or vest)
class StatusIndicator extends StatelessWidget {
  final String label;
  final bool isPresent;
  final IconData icon;

  const StatusIndicator({
    super.key,
    required this.label,
    required this.isPresent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPresent
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPresent
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: isPresent
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            isPresent ? Icons.check_circle : Icons.cancel,
            color: isPresent
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            size: 28,
          ),
        ],
      ),
    );
  }
}
