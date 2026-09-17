import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;

  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }

    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  void open() {
    openedAt = DateTime.now();
  }

  List<Book> get _books => items.whereType<Book>().toList();

  List<String> get everyTitle =>
      items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      _books.where((book) => book.year > 2010).toList();

  // reduce is not used because it cannot start with an empty collection.
  double get averagePages =>
      _books.isEmpty
          ? 0.0
          : _books.fold<int>(
        0,
            (sum, book) => sum + book.pages,
      ) /
          _books.length;

  Map<String, int> get booksByAuthor => {
    for (final author in authorNames)
      author: _books
          .where((book) => book.author.name == author)
          .length,
  };

  Set<String> get authorNames =>
      _books.map((book) => book.author.name).toSet();

  Set<Genre> get genres =>
      _books.map((book) => book.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',
    for (final book in _books) '${book.title} (${book.year})',
    ...authorNames,
    if (_books.any((book) => book.pages == 0)) '(incomplete data)',
  ];

  String buildReport() => _cachedReport ??= displayList.join('\n');
}