
extension UnicornIntExtension on int? {
  int get orZero => this ?? 0;
}
