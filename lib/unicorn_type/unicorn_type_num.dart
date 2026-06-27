extension UnicornIntExtension on int? {
  int get orZero => this ?? 0;
}

extension UnicornDoubleExtension on double? {
  double get orZero => this ?? 0.0;
}
