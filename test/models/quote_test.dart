import 'package:flutter_test/flutter_test.dart';
import 'package:quote_widget_app/models/quote.dart';

void main() {
  group('Quote', () {
    test('fromJson parses anime quote', () {
      final json = {
        'text': 'Never give up!',
        'author': 'Naruto',
        'source': 'bundled',
        'anime': 'Naruto',
      };
      final quote = Quote.fromJson(json);
      expect(quote.text, 'Never give up!');
      expect(quote.author, 'Naruto');
      expect(quote.source, 'bundled');
      expect(quote.anime, 'Naruto');
      expect(quote.character, isNull);
    });

    test('toJson round-trips', () {
      final quote = Quote(
        text: 'Test',
        author: 'Author',
        source: 'anime',
      );
      expect(Quote.fromJson(quote.toJson()).text, 'Test');
    });
  });
}
