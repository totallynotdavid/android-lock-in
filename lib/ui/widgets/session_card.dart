import 'package:flutter/material.dart';
import '../../models/timer_session.dart';
import 'dart:async';

class SessionCard extends StatefulWidget {
  final TimerSession session;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SessionCard({
    super.key,
    required this.session,
    required this.onStart,
    required this.onStop,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Set up timer to refresh UI every second when session is active
    if (widget.session.isActive) {
      _startRefreshTimer();
    }
  }

  @override
  void didUpdateWidget(SessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start or stop refresh timer based on session active state
    if (!oldWidget.session.isActive && widget.session.isActive) {
      _startRefreshTimer();
    } else if (oldWidget.session.isActive && !widget.session.isActive) {
      _refreshTimer?.cancel();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        return '$hours:${remainingMinutes.toString().padLeft(2, '0')}';
      }
    }
  }

  String _formatRemainingTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return '${hours > 0 ? '${hours}h ' : ''}${remainingMinutes}m remaining';
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final isActive = session.isActive;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(session.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        widget.onDelete();
        return false; // Don't dismiss yet, let the dialog handle it
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? colorScheme.primary.withValues(alpha: 0.1)
                                    : colorScheme.onSurface.withValues(
                                      alpha: 0.05,
                                    ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.timer_outlined,
                            color:
                                isActive
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Every ${_formatDuration(session.intervalMinutes)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.more_vert),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Progress indicator (only when active)
            if (isActive)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatRemainingTime(session.remainingMinutes),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(session.progressPercentage * 100).round()}%',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: session.progressPercentage,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            // Action button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child:
                  isActive
                      ? OutlinedButton.icon(
                        onPressed: widget.onStop,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                      : FilledButton.icon(
                        onPressed: widget.onStart,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
