enum StatementSource {
  ofx,
  csv;

  static StatementSource fromString(String value) {
    return StatementSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StatementSource.ofx,
    );
  }
}
