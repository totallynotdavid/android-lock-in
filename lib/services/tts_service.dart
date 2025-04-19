import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class TTSService {
  static final TTSService _instance = TTSService._();
  factory TTSService() => _instance;

  TTSService._() {
    _initialize();
  }

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _initialize() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speakCurrentTime({String? sessionName}) async {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm a').format(now);

    String message;

    if (sessionName != null) {
      message = '$sessionName session. The time is $timeString.';
    } else {
      message = 'The time is $timeString.';
    }

    await _flutterTts.speak(message);
  }

  Future<void> speakSessionEnd(String sessionName) async {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm a').format(now);

    final message =
        'Your $sessionName session has ended. The time is $timeString.';

    await _flutterTts.speak(message);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
