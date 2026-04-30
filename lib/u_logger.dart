/// U$Logger: Un logger simple et modulaire pour Unicorn.
/// Utilisation : U$Logger.log('message');

class U$Logger {
  /// Affiche un message dans la console avec un préfixe [U$].
  static void log(Object? message) {
    final now = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('[U\$][$now] $message');
  }
}
