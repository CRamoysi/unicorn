/// Unicorn Toolkit - Point d'entrée
import 'dart:developer' as dev;


/// Exporte tous les outils Unicorn
part 'unicorn_logger.dart';
part 'unicorn_collection.dart';
part 'unicorn_type.dart';

/// Utilitaire Unicorn
const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kDebugMode = !kReleaseMode && !kProfileMode;

class U$ {
  //singleton
  static final U$ _instance = U$._internal();

  factory U$() {
    return _instance;
  }

  U$._internal();

  // String icone licorn
  static const String unicornIcon = "🦄";

  // Flag mode debug
  static bool get isDebug => kDebugMode;
  static bool forceDebug = false; // Toujours commit à false
  static bool get canDebug => isDebug || forceDebug;
}
