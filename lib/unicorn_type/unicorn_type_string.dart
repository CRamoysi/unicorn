extension UnicornStringNullableExtension on String? {
  String? get trimOrNull {
    if (this == null) return null;
    final trimmed = this!.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String trim() => this?.trim() ?? '';

  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

extension UnicornStringExtension on String {
  String? get trimOrNull {
    final trimmed = this.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool get isNullOrEmpty => this.isEmpty;
  bool get isNotNullOrEmpty => this.isNotEmpty;
}
