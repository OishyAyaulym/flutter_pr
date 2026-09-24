import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  final books = rawBooks.map((rawBook) => Book.fromJson(rawBook)).toList();

  for (final book in books) {
    library.add(book);
  }

  library.open();

  print('FIND BY TITLE');
  print(library.findByTitle('Clean Code'));

  print('\nCOUNTRY OF');
  print('Clean Code: ${library.countryOf('Clean Code')}');
  print('Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Broken Record: ${library.countryOf('Broken Record')}');

  print('\nEVERY TITLE');
  print(library.everyTitle);

  print('\nBOOKS AFTER 2010');
  print(library.booksAfter2010);

  print('\nAVERAGE PAGES');
  print(library.averagePages);

  print('\nBOOKS BY AUTHOR');
  print(library.booksByAuthor);

  print('\nAUTHOR NAMES');
  print(library.authorNames);

  print('\nGENRES');
  print(library.genres);

  print('\nDISPLAY LIST');
  print(library.displayList.join('\n'));

  print('\nCACHED REPORT');
  print(library.buildReport());

  print('\nRECORD');
  final stats = statsOf(books);
  print('count: ${stats.count}');
  print('avgPages: ${stats.avgPages}');

  print('\nSHELF STATES');
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('shelf collapsed')));
}
