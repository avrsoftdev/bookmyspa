class FaqItem {
  final String question;
  final String answer;
  FaqItem({required this.question, required this.answer});
}

class FaqSection {
  final String title;
  final List<FaqItem> items;
  FaqSection({required this.title, required this.items});

  FaqSection filtered(String query) {
    if (query.isEmpty) return this;
    final q = query.toLowerCase();
    final filteredItems = items.where((i) {
      return i.question.toLowerCase().contains(q) ||
          i.answer.toLowerCase().contains(q);
    }).toList();
    return FaqSection(title: title, items: filteredItems);
  }
}
