
extension UnicornDoubleExtension on double? {
  double get orZero => this ?? 0.0;
}
