import 'package:flutter/material.dart';

class TimerPreview extends StatelessWidget {
  final int intervalMinutes;
  final int durationMinutes;

  const TimerPreview({
    super.key,
    required this.intervalMinutes,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate how many announcements will occur
    final announcementCount = (durationMinutes / intervalMinutes).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session Preview', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          // Timeline visualization
          SizedBox(
            height: 64,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final markersToShow =
                    announcementCount > 10 ? 10 : announcementCount;

                return Stack(
                  children: [
                    // Line
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 32,
                      child: Container(
                        height: 2,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),

                    // Start point
                    Positioned(
                      left: 0,
                      top: 28,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Announcement markers
                    for (int i = 1; i < markersToShow; i++)
                      Positioned(
                        left: (width / markersToShow) * i,
                        top: 28,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                    // Announcement labels
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Text('Start', style: theme.textTheme.bodySmall),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Text('End', style: theme.textTheme.bodySmall),
                    ),

                    // Mid markers label
                    if (markersToShow > 4)
                      Positioned(
                        left: width / 2 - 25,
                        bottom: 0,
                        child: Text(
                          'Announcements',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Summary text
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: 'You will hear ',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                TextSpan(
                  text: '$announcementCount time announcements ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: 'over ',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                TextSpan(
                  text: _formatDuration(durationMinutes),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        return '$hours h $remainingMinutes min';
      }
    }
  }
}

class MinimalistTimePicker extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final void Function(int) onChanged;
  final String unit;

  const MinimalistTimePicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - step) : null,
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 32,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            Text(
              value.toString(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(unit, style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: value < max ? () => onChanged(value + step) : null,
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 32,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
