import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/quote.dart';
import '../repositories/widget_data_repository.dart';
import '../services/image_service.dart';
import '../services/quote_service.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _quoteService = QuoteService();
  final _imageService = ImageService();
  final _repo = WidgetDataRepository();

  String? _imagePath;
  Quote? _quote;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<AppSettings> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final styleStr = prefs.getString('quote_style') ?? 'both';
    final userPaths = prefs.getStringList('user_image_paths') ?? [];
    return AppSettings(
      quoteStyle: QuoteStyle.values.firstWhere(
        (e) => e.name == styleStr,
        orElse: () => QuoteStyle.both,
      ),
      userImagePaths: userPaths,
    );
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final settings = await _loadSettings();
      final quote = await _quoteService.getRandomQuote(settings.quoteStyle);
      final imagePath =
          await _imageService.getRandomImagePath(settings.userImagePaths);
      await _repo.saveAndUpdate(quote, imagePath);
      setState(() {
        _quote = quote;
        _imagePath = imagePath;
        _loading = false;
      });
    } catch (e) {
      // Fallback: load a bundled quote so screen is never blank
      try {
        final fallback = await _quoteService.getRandomQuote(QuoteStyle.both);
        setState(() {
          _quote = fallback;
          _loading = false;
        });
      } catch (_) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _loading ? null : _refresh,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_imagePath != null && File(_imagePath!).existsSync())
              Image.file(
                File(_imagePath!),
                fit: BoxFit.cover,
              )
            else
              const ColoredBox(color: Colors.black),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (!_loading && _quote != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${_quote!.text}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— ${_quote!.author}${_quote!.anime != null ? ', ${_quote!.anime}' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                  _refresh();
                },
                backgroundColor: Colors.white.withOpacity(0.15),
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
