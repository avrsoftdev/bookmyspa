import 'package:shared_preferences/shared_preferences.dart';

class SubcategoryPreferences {
  static const _key = 'most_booked_subcategories';

  /// Increment subcategory booking count when a user views or books a subcategory
  Future<void> incrementSubcategory(String subcategory) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = prefs.getStringList(_key) ?? [];
    final Map<String, int> subcategoryCounts = {};

    for (final item in currentData) {
      final parts = item.split(':');
      if (parts.length == 2) {
        subcategoryCounts[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }

    subcategoryCounts[subcategory] = (subcategoryCounts[subcategory] ?? 0) + 1;

    final List<String> newData = subcategoryCounts.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await prefs.setStringList(_key, newData);
  }

  /// Get top 5 most booked subcategories
  Future<List<String>> getMostBookedSubcategories() async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = prefs.getStringList(_key) ?? [];
    final Map<String, int> subcategoryCounts = {};

    for (final item in currentData) {
      final parts = item.split(':');
      if (parts.length == 2) {
        subcategoryCounts[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }

    final sortedSubcategories = subcategoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSubcategories.map((entry) => entry.key).take(5).toList();
  }
}
