import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import '../../models/timer_session.dart';
import '../widgets/session_card.dart';
import '../widgets/add_session_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timekeeper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<SessionProvider>(
        builder: (context, provider, child) {
          final sessions = provider.sessions;

          if (sessions.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              return SessionCard(
                session: sessions[index],
                onStart: () => provider.startSession(sessions[index].id),
                onStop: () => provider.stopSession(sessions[index].id),
                onEdit: () => _showEditSessionSheet(context, sessions[index]),
                onDelete:
                    () => _showDeleteConfirmation(context, sessions[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Stay on track with time reminders',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create your first timer to get time announcements at regular intervals',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showAddSessionSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Timer'),
          ),
        ],
      ),
    );
  }

  void _showAddSessionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddSessionSheet(),
    );
  }

  void _showEditSessionSheet(BuildContext context, TimerSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddSessionSheet(sessionToEdit: session),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TimerSession session) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Timer'),
            content: Text('Are you sure you want to delete "${session.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Provider.of<SessionProvider>(
                    context,
                    listen: false,
                  ).removeSession(session.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Timekeeper'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timekeeper helps you stay on task by announcing the current time at regular intervals.',
                ),
                SizedBox(height: 16),
                Text(
                  'How to use:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('1. Create a new timer'),
                Text('2. Choose how often you want time announcements'),
                Text('3. Set how long the session should last'),
                Text('4. Tap start and focus on your work!'),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }
}
