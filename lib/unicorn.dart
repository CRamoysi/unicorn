/// Unicorn Toolkit - Point d'entrée

/// Exporte tous les outils Unicorn
export 'unicorn_logger.dart';
// Extensions pour les collections
export 'unicorn_collection.dart';
// Types et extensions de parsing
export 'unicorn_type.dart';

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
