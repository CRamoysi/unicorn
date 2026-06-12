/// Core Unicorn runtime flags and utility singleton.
const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kDebugMode = !kReleaseMode && !kProfileMode;

class U$ {
  static final U$ _instance = U$._internal();

  factory U$() {
    return _instance;
  }

  U$._internal();

  static const String unicornIcon = "🦄";

  static bool get isDebug => kDebugMode;
  static bool forceDebug = false;
  static bool get canDebug => isDebug || forceDebug;
}