import 'package:flutter_test/flutter_test.dart';
import 'package:quote_widget_app/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('defaults are correct', () {
      const s = AppSettings();
      expect(s.refreshIntervalMinutes, 30);
      expect(s.quoteStyle, QuoteStyle.both);
      expect(s.userImagePaths, isEmpty);
    });

    test('fromJson round-trips', () {
      const s = AppSettings(
        refreshIntervalMinutes: 60,
        quoteStyle: QuoteStyle.anime,
        userImagePaths: ['/path/img.jpg'],
      );
      final s2 = AppSettings.fromJson(s.toJson());
      expect(s2.refreshIntervalMinutes, 60);
      expect(s2.quoteStyle, QuoteStyle.anime);
      expect(s2.userImagePaths, ['/path/img.jpg']);
    });
  });
}
