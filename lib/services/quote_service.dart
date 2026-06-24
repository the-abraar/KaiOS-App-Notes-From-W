import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/app_settings.dart';
import '../models/quote.dart';
import 'database_helper.dart';

class QuoteService {
  static const _animechanUrl = 'https://animechan.io/api/v1/quotes/random';
  static const _zenquotesUrl = 'https://zenquotes.io/api/random';

  final http.Client _httpClient;
  final DatabaseHelper _db;
  List<Quote>? _bundledQuotes;

  QuoteService({http.Client? httpClient, DatabaseHelper? db})
      : _httpClient = httpClient ?? http.Client(),
        _db = db ?? DatabaseHelper.instance;

  Future<List<Quote>> _loadBundled() async {
    _bundledQuotes ??= await rootBundle
        .loadString('assets/quotes.json')
        .then((s) => (jsonDecode(s) as List)
            .map((e) => Quote.fromJson(e as Map<String, dynamic>))
            .toList());
    return _bundledQuotes!;
  }

  Future<Quote> getRandomQuote(QuoteStyle style) async {
    final sourceFilter = style == QuoteStyle.both
        ? 'all'
        : style == QuoteStyle.anime
            ? 'anime'
            : 'inspirational';

    final cached = await _db.getQuotesBySource(sourceFilter);
    if (cached.isNotEmpty) {
      return cached[Random().nextInt(cached.length)];
    }

    // Cache empty — try API refresh, fall back to bundled
    try {
      await refreshCache(style);
      final fresh = await _db.getQuotesBySource(sourceFilter);
      if (fresh.isNotEmpty) return fresh[Random().nextInt(fresh.length)];
    } catch (_) {}

    final bundled = await _loadBundled();
    return bundled[Random().nextInt(bundled.length)];
  }

  Future<void> refreshCache(QuoteStyle style) async {
    if (style == QuoteStyle.anime || style == QuoteStyle.both) {
      await _fetchAndStore(_animechanUrl, 'anime', _parseAnimechan);
    }
    if (style == QuoteStyle.inspirational || style == QuoteStyle.both) {
      await _fetchAndStore(_zenquotesUrl, 'inspirational', _parseZenquotes);
    }
  }

  Future<void> _fetchAndStore(
    String url,
    String source,
    List<Quote> Function(dynamic) parser,
  ) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) return;
    final quotes = parser(jsonDecode(response.body));
    if (quotes.isEmpty) return;
    await _db.clearQuotesBySource(source);
    await _db.insertQuotes(quotes);
  }

  List<Quote> _parseAnimechan(dynamic json) {
    if (json is Map && json['status'] == 'success') {
      final data = json['data'] as Map<String, dynamic>;
      return [
        Quote(
          text: data['content'] as String,
          author: (data['character'] as Map)['name'] as String,
          source: 'anime',
          character: (data['character'] as Map)['name'] as String,
          anime: ((data['character'] as Map)['anime'] as Map)['name'] as String,
        )
      ];
    }
    return [];
  }

  List<Quote> _parseZenquotes(dynamic json) {
    if (json is List && json.isNotEmpty) {
      return [
        Quote(
          text: json[0]['q'] as String,
          author: json[0]['a'] as String,
          source: 'inspirational',
        )
      ];
    }
    return [];
  }
}
