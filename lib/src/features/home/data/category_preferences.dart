import 'package:shared_preferences/shared_preferences.dart';

class CategoryPreferences {
  static const _key = 'popular_categories';

  Future<void> incrementCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = prefs.getStringList(_key) ?? [];
    final Map<String, int> categoryCounts = {};

    for (final item in currentData) {
      final parts = item.split(':');
      if (parts.length == 2) {
        categoryCounts[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }

    categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

    final List<String> newData = categoryCounts.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await prefs.setStringList(_key, newData);
  }

  Future<List<String>> getPopularCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = prefs.getStringList(_key) ?? [];
    final Map<String, int> categoryCounts = {};

    for (final item in currentData) {
      final parts = item.split(':');
      if (parts.length == 2) {
        categoryCounts[parts[0]] = int.tryParse(parts[1]) ?? 0;
      }
    }

    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories.map((entry) => entry.key).take(5).toList();
  }
}
