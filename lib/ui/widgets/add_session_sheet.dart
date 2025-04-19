import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import '../../models/timer_session.dart';
import 'custom_components.dart';

class AddSessionSheet extends StatefulWidget {
  final TimerSession? sessionToEdit;

  const AddSessionSheet({super.key, this.sessionToEdit});

  @override
  State<AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<AddSessionSheet> {
  final _nameController = TextEditingController();
  int _intervalMinutes = 5; // Default: 5 minutes
  int _durationMinutes = 60; // Default: 1 hour
  bool _isEditMode = false;

  final List<int> _intervalPresets = [1, 5, 10, 15, 30, 60];
  final List<int> _durationPresets = [15, 30, 60, 90, 120, 180];

  @override
  void initState() {
    super.initState();

    if (widget.sessionToEdit != null) {
      _isEditMode = true;
      _nameController.text = widget.sessionToEdit!.name;
      _intervalMinutes = widget.sessionToEdit!.intervalMinutes;
      _durationMinutes = widget.sessionToEdit!.durationMinutes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveSession() {
    final name = _nameController.text.trim();

    final provider = Provider.of<SessionProvider>(context, listen: false);

    if (_isEditMode) {
      provider.updateSession(
        widget.sessionToEdit!.id,
        name: name.isNotEmpty ? name : null,
        intervalMinutes: _intervalMinutes,
        durationMinutes: _durationMinutes,
      );
    } else {
      provider.addSession(
        _intervalMinutes,
        _durationMinutes,
        name: name.isNotEmpty ? name : null,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditMode ? 'Edit Timer' : 'New Timer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name field - optional, collapsed by default
            ExpansionTile(
              title: const Text('Timer Name (Optional)'),
              initiallyExpanded: _isEditMode && _nameController.text.isNotEmpty,
              childrenPadding: const EdgeInsets.symmetric(vertical: 8),
              tilePadding: EdgeInsets.zero,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a name for this timer',
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Interval selection
            Text(
              'Announce time every',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Preset buttons for interval
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _intervalPresets.map((minutes) {
                    final isSelected = _intervalMinutes == minutes;
                    return ChoiceChip(
                      label: Text(_formatIntervalText(minutes)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _intervalMinutes = minutes;
                          });
                        }
                      },
                      backgroundColor: Colors.transparent,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
            ),

            // Custom interval entry
            if (!_intervalPresets.contains(_intervalMinutes))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ChoiceChip(
                  label: Text('$_intervalMinutes minutes'),
                  selected: true,
                  onSelected: (_) {},
                  backgroundColor: Colors.transparent,
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Custom interval slider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Text('1m'),
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 60,
                      divisions: 59,
                      value: _intervalMinutes.toDouble().clamp(1, 60),
                      onChanged: (value) {
                        setState(() {
                          _intervalMinutes = value.round();
                        });
                      },
                    ),
                  ),
                  const Text('60m'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Duration selection
            Text(
              'Session length',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Preset buttons for duration
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _durationPresets.map((minutes) {
                    final isSelected = _durationMinutes == minutes;
                    return ChoiceChip(
                      label: Text(_formatDurationText(minutes)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _durationMinutes = minutes;
                          });
                        }
                      },
                      backgroundColor: Colors.transparent,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
            ),

            // Custom duration entry
            if (!_durationPresets.contains(_durationMinutes))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ChoiceChip(
                  label: Text(_formatDurationText(_durationMinutes)),
                  selected: true,
                  onSelected: (_) {},
                  backgroundColor: Colors.transparent,
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Custom duration slider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Text('15m'),
                  Expanded(
                    child: Slider(
                      min: 15,
                      max: 240,
                      divisions: 45,
                      value: _durationMinutes.toDouble().clamp(15, 240),
                      onChanged: (value) {
                        setState(() {
                          _durationMinutes = value.round();
                        });
                      },
                    ),
                  ),
                  const Text('4h'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            TimerPreview(
              intervalMinutes: _intervalMinutes,
              durationMinutes: _durationMinutes,
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveSession,
                child: Text(_isEditMode ? 'Save Changes' : 'Create Timer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatIntervalText(int minutes) {
    if (minutes == 1) return '1 min';
    if (minutes < 60) return '$minutes mins';
    return '1 hour';
  }

  String _formatDurationText(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        return '$hours:${remainingMinutes.toString().padLeft(2, '0')} hours';
      }
    }
  }
}
