
extension UnicornStringNullableExtension on String? {
  String? get trimOrNull {
    if (this == null) return null;
    final trimmed = this!.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String trim() => this?.trim() ?? '';

}

extension UnicornStringExtension on String {
  String? get trimOrNull {
    final trimmed = this.trim();
    return trimmed.isEmpty ? null : trimmed;
  }



}
