abstract final class FormValidators {
  static const certificationTitleLimit = 255;

  static String? requiredText(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (maxLength != null && text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  /// Django menyimpan tahun sebagai PositiveIntegerField, termasuk nilai nol.
  static String? certificationYear(String? value) {
    final missing = requiredText(value, 'Tahun');
    if (missing != null) return missing;
    final text = value!.trim();
    final year = int.tryParse(text);
    if (!RegExp(r'^[0-9]+$').hasMatch(text) ||
        year == null ||
        year < 0 ||
        year > 2147483647) {
      return 'Tahun harus bilangan bulat antara 0 dan 2147483647.';
    }
    return null;
  }
}
