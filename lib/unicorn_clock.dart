// ignore_for_file: non_constant_identifier_names

import 'package:unicorn/unicorn_logger.dart';

class U$Clock {
  // Singleton
  static final U$Clock _instance = U$Clock._internal();
  factory U$Clock() => _instance;
  U$Clock._internal();

  final Map<String, _U$Stopwatch> _clocks = {};
  final Map<String, bool> _running = {};

  // Demarre l'horloge pour un nom donne.
  void start(String name, {bool reset = true}) {
    if (_running[name] == true && reset == false) {
      throw StateError('Stopwatch $name already running');
    }
    if (reset == true) {
      _clocks.remove(name);
      _running.remove(name);
    }

    _running[name] = true;
    _clocks[name] = _U$Stopwatch(name);
  }

  // Arrete l'horloge.
  void stop(String name) {
    if (_running[name] != true) {
      throw StateError('Stopwatch $name not running');
    }

    _running[name] = false;
    _clocks[name]!.stop();
  }

  // Logge le temps ecoule pour ce chrono.
  void show(String name) {
    if (_running[name] == true) {
      throw StateError('Stopwatch $name still running');
    }
    final clock = _clocks[name];
    if (clock == null) {
      throw StateError('Stopwatch $name not found');
    }

    U$Log('Stopwatch $name: ${clock.duration}');
  }

  Duration getDuration(String name) {
    if (_running[name] == true) {
      throw StateError('Stopwatch $name still running');
    }

    final clock = _clocks[name];
    if (clock == null) {
      throw StateError('Stopwatch $name not found');
    }

    return clock.duration;
  }
}

class _U$Stopwatch {
  final String name;
  final DateTime start;
  DateTime? end;

  _U$Stopwatch(this.name) : start = DateTime.now();

  void stop() {
    end = DateTime.now();
  }

  Duration get duration {
    if (end == null) {
      throw StateError('Stopwatch not stopped');
    }
    return end!.difference(start);
  }

  @override
  String toString() {
    return '_U\$Stopwatch{name: $name, start: $start, end: $end}';
  }
}
