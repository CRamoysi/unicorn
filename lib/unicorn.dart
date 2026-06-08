/// Unicorn Toolkit - Point d'entrée
/// Exporte tous les outils Unicorn

export 'u_logger.dart';
export 'u_collection_extensions.dart';

/// Utilitaire Unicorn

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
  static const bool forceDebug = false; // Toujours commit à false
  static bool get canDebug => isDebug || forceDebug;
}
