import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(const TimePressureApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class TimePressureApp extends StatelessWidget {
  const TimePressureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Pressure',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class AlarmSession {
  final String id;
  final String name;
  final int intervalMinutes;
  final int durationMinutes;
  bool isActive;

  AlarmSession({
    required this.id,
    required this.name,
    required this.intervalMinutes,
    required this.durationMinutes,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'intervalMinutes': intervalMinutes,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
    };
  }

  factory AlarmSession.fromJson(Map<String, dynamic> json) {
    return AlarmSession(
      id: json['id'],
      name: json['name'],
      intervalMinutes: json['intervalMinutes'],
      durationMinutes: json['durationMinutes'],
      isActive: json['isActive'] ?? false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<AlarmSession> _alarmSessions = [];
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAlarmSessions();
    _configureTextToSpeech();
  }

  Future<void> _configureTextToSpeech() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _loadAlarmSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString('alarmSessions');

    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      setState(() {
        _alarmSessions.clear();
        _alarmSessions.addAll(
          decoded.map((item) => AlarmSession.fromJson(item)).toList(),
        );
      });

      // Resume active sessions
      for (var session in _alarmSessions) {
        if (session.isActive) {
          _startAlarmSession(session);
        }
      }
    }
  }

  Future<void> _saveAlarmSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _alarmSessions.map((s) => s.toJson()).toList(),
    );
    await prefs.setString('alarmSessions', encoded);
  }

  void _startAlarmSession(AlarmSession session) {
    session.isActive = true;
    _speakCurrentTime();

    // Set up timer to repeat at the specified interval
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(minutes: session.intervalMinutes),
      (_) => _speakCurrentTime(),
    );

    // Set up timer to end the session after the specified duration
    Future.delayed(Duration(minutes: session.durationMinutes), () {
      if (session.isActive) {
        setState(() {
          session.isActive = false;
          _saveAlarmSessions();
        });
        _timer?.cancel();
        _speakCurrentTime(
          withMessage: 'Your ${session.name} session has ended.',
        );
      }
    });

    _saveAlarmSessions();
  }

  void _stopAlarmSession(AlarmSession session) {
    setState(() {
      session.isActive = false;
      _timer?.cancel();
      _saveAlarmSessions();
    });
  }

  void _speakCurrentTime({String? withMessage}) async {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm a').format(now);

    final message =
        withMessage != null
            ? '$withMessage The current time is $timeString.'
            : 'The current time is $timeString.';

    await _flutterTts.speak(message);

    // Also show a notification
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'time_pressure_channel',
          'Time Pressure Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Time Check',
      message,
      platformDetails,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _alarmSessions.isEmpty
              ? _buildEmptyState()
              : _buildAlarmSessionsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlarmDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_add,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No time pressure alarms yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first alarm to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmSessionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alarmSessions.length,
      itemBuilder: (context, index) {
        final session = _alarmSessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        session.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditAlarmDialog(session),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAlarmSession(session),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reminds every ${session.intervalMinutes} minutes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Session length: ${_formatDuration(session.durationMinutes)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        if (session.isActive) {
                          _stopAlarmSession(session);
                        } else {
                          _startAlarmSession(session);
                        }
                      });
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(session.isActive ? 'Stop' : 'Start'),
                  ),
                ),
                if (session.isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Active',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
        return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes minutes';
      }
    }
  }

  void _showAddAlarmDialog() {
    final nameController = TextEditingController();
    final intervalController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Alarm'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Alarm Name',
                      hintText: 'e.g., Design Task',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Remind Every (minutes)',
                      hintText: 'e.g., 10',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Session Duration (minutes)',
                      hintText: 'e.g., 120',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final intervalText = intervalController.text.trim();
                  final durationText = durationController.text.trim();

                  if (name.isEmpty ||
                      intervalText.isEmpty ||
                      durationText.isEmpty) {
                    return;
                  }

                  final interval = int.tryParse(intervalText);
                  final duration = int.tryParse(durationText);

                  if (interval == null ||
                      interval <= 0 ||
                      duration == null ||
                      duration <= 0) {
                    return;
                  }

                  final newSession = AlarmSession(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    intervalMinutes: interval,
                    durationMinutes: duration,
                  );

                  setState(() {
                    _alarmSessions.add(newSession);
                    _saveAlarmSessions();
                  });

                  Navigator.of(context).pop();
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showEditAlarmDialog(AlarmSession session) {
    final nameController = TextEditingController(text: session.name);
    final intervalController = TextEditingController(
      text: session.intervalMinutes.toString(),
    );
    final durationController = TextEditingController(
      text: session.durationMinutes.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Alarm'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Alarm Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Remind Every (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Session Duration (minutes)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final intervalText = intervalController.text.trim();
                  final durationText = durationController.text.trim();

                  if (name.isEmpty ||
                      intervalText.isEmpty ||
                      durationText.isEmpty) {
                    return;
                  }

                  final interval = int.tryParse(intervalText);
                  final duration = int.tryParse(durationText);

                  if (interval == null ||
                      interval <= 0 ||
                      duration == null ||
                      duration <= 0) {
                    return;
                  }

                  setState(() {
                    // If session is active, we need to restart it with new parameters
                    final wasActive = session.isActive;
                    if (wasActive) {
                      _stopAlarmSession(session);
                    }

                    session.isActive = false;
                    final index = _alarmSessions.indexWhere(
                      (s) => s.id == session.id,
                    );
                    if (index != -1) {
                      _alarmSessions[index] = AlarmSession(
                        id: session.id,
                        name: name,
                        intervalMinutes: interval,
                        durationMinutes: duration,
                      );

                      if (wasActive) {
                        _startAlarmSession(_alarmSessions[index]);
                      }

                      _saveAlarmSessions();
                    }
                  });

                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteAlarmSession(AlarmSession session) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Alarm'),
            content: Text('Are you sure you want to delete "${session.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    if (session.isActive) {
                      _stopAlarmSession(session);
                    }
                    _alarmSessions.removeWhere((s) => s.id == session.id);
                    _saveAlarmSessions();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
