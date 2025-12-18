class Suggestion {
  final String displayText;
  final String searchText;
  final String subtitle;

  Suggestion({
    required this.displayText,
    required this.searchText,
    this.subtitle = '',
  });
}