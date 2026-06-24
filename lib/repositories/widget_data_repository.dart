import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class WidgetDataRepository {
  static const _key = 'widget_data';
  static const _androidName = 'QuoteWidgetProvider';
  static const _iosName = 'QuoteWidget';

  final bool _testing;
  WidgetDataRepository() : _testing = false;
  WidgetDataRepository.forTesting() : _testing = true;

  Future<void> saveAndUpdate(Quote quote, String imagePath) async {
    final payload = jsonEncode({
      'quote': quote.text,
      'author': quote.author,
      'source': quote.source,
      'imagePath': imagePath,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    if (_testing) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, payload);
      return;
    }

    await HomeWidget.saveWidgetData<String>(_key, payload);
    await HomeWidget.updateWidget(
      androidName: _androidName,
      iOSName: _iosName,
    );
  }

  Future<Map<String, dynamic>?> load() async {
    if (_testing) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      return raw != null ? jsonDecode(raw) as Map<String, dynamic> : null;
    }
    final raw = await HomeWidget.getWidgetData<String>(_key);
    return raw != null ? jsonDecode(raw) as Map<String, dynamic> : null;
  }
}
