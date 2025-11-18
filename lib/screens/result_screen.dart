import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controllers/detection_controller.dart';
import '../widgets/status_indicator.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectionState = ref.watch(detectionControllerProvider);
    final controller = ref.read(detectionControllerProvider.notifier);
    final theme = Theme.of(context);

    final result = detectionState.result;

    if (result == null) {
      // If no result, go back to camera
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isCompliant = result.isCompliant;
    final formattedTime = _formatTimestamp(result.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Worker identification card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        result.isRecognized ? Icons.person : Icons.person_off,
                        size: 80,
                        color: result.isRecognized
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        result.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // PPE Status indicators
              Text(
                'PPE Equipment Status',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              StatusIndicator(
                label: 'Safety Helmet',
                isPresent: result.helmet,
                icon: Icons.construction,
              ),
              const SizedBox(height: 12),
              
              StatusIndicator(
                label: 'Safety Vest',
                isPresent: result.vest,
                icon: Icons.safety_check,
              ),
              const SizedBox(height: 32),

              // Compliance status message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompliant
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompliant ? Icons.check_circle : Icons.warning,
                      color: isCompliant
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCompliant
                            ? 'All safety requirements met'
                            : _getComplianceMessage(result),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isCompliant
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              if (isCompliant)
                _buildClockButton(context, ref, controller, theme)
              else
                _buildResetButton(context, ref, controller, theme),
              
              const SizedBox(height: 12),
              
              // Always show a way to go back
              if (isCompliant)
                OutlinedButton(
                  onPressed: () => _onReset(context, controller),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClockButton(
    BuildContext context,
    WidgetRef ref,
    DetectionController controller,
    ThemeData theme,
  ) {
    final detectionState = ref.watch(detectionControllerProvider);
    final buttonText = controller.getClockButtonText();
    final isLoading = detectionState.isClockingEvent;

    return FilledButton.icon(
      onPressed: isLoading ? null : () => _onClockEvent(context, controller),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(controller.isMorning() ? Icons.login : Icons.logout),
      label: Text(isLoading ? 'Processing...' : buttonText),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildResetButton(
    BuildContext context,
    WidgetRef ref,
    DetectionController controller,
    ThemeData theme,
  ) {
    return FilledButton.icon(
      onPressed: () => _onReset(context, controller),
      icon: const Icon(Icons.refresh),
      label: const Text('Reset'),
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _onClockEvent(
    BuildContext context,
    DetectionController controller,
  ) async {
    final eventType = controller.getClockEventType();
    final success = await controller.recordClockEvent(eventType);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${controller.getClockButtonText()} successful!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _onReset(context, controller);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to record clock event'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _onReset(BuildContext context, DetectionController controller) {
    controller.reset();
    context.go('/');
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  String _getComplianceMessage(result) {
    if (!result.isRecognized) {
      return 'Worker not recognized';
    } else if (!result.helmet && !result.vest) {
      return 'Missing helmet and vest';
    } else if (!result.helmet) {
      return 'Missing safety helmet';
    } else if (!result.vest) {
      return 'Missing safety vest';
    }
    return 'Safety requirements not met';
  }
}
