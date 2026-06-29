import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/image_service.dart';
import '../services/refresh_scheduler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _imageService = ImageService();
  final _picker = ImagePicker();

  int _intervalMinutes = 30;
  QuoteStyle _quoteStyle = QuoteStyle.both;
  List<String> _userImagePaths = [];
  bool _unlockRefresh = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _intervalMinutes = prefs.getInt('refresh_interval_minutes') ?? 30;
      _quoteStyle = QuoteStyle.values.firstWhere(
        (e) => e.name == (prefs.getString('quote_style') ?? 'both'),
        orElse: () => QuoteStyle.both,
      );
      _userImagePaths = prefs.getStringList('user_image_paths') ?? [];
      _unlockRefresh = prefs.getBool('unlock_refresh_enabled') ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refresh_interval_minutes', _intervalMinutes);
    await prefs.setString('quote_style', _quoteStyle.name);
    await prefs.setStringList('user_image_paths', _userImagePaths);
    await prefs.setBool('unlock_refresh_enabled', _unlockRefresh);
    await RefreshScheduler.schedule(_intervalMinutes);
  }

  Future<void> _addPhotos() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    final newPaths = <String>[];
    for (final img in picked) {
      final copied = await _imageService.copyUserImage(img.path);
      newPaths.add(copied);
    }
    setState(() => _userImagePaths.addAll(newPaths));
    await _save();
  }

  Future<void> _resetImages() async {
    setState(() => _userImagePaths = []);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionLabel('Refresh Interval'),
                ...([15, 30, 60, 120].map((m) => RadioListTile<int>(
                      title: Text('$m minutes',
                          style: const TextStyle(color: Colors.white)),
                      value: m,
                      groupValue: _intervalMinutes,
                      activeColor: Colors.white,
                      onChanged: (v) async {
                        setState(() => _intervalMinutes = v!);
                        await _save();
                      },
                    ))),
                const Divider(color: Colors.white24),
                _SectionLabel('Quote Style'),
                ...QuoteStyle.values.map((style) => RadioListTile<QuoteStyle>(
                      title: Text(
                          style.name[0].toUpperCase() + style.name.substring(1),
                          style: const TextStyle(color: Colors.white)),
                      value: style,
                      groupValue: _quoteStyle,
                      activeColor: Colors.white,
                      onChanged: (v) async {
                        setState(() => _quoteStyle = v!);
                        await _save();
                      },
                    )),
                const Divider(color: Colors.white24),
                _SectionLabel('Widget'),
                SwitchListTile(
                  title: const Text('Refresh photo on every unlock',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                      'Shows a new photo each time you unlock your phone',
                      style: TextStyle(color: Colors.white54)),
                  value: _unlockRefresh,
                  activeColor: Colors.white,
                  onChanged: (v) async {
                    setState(() => _unlockRefresh = v);
                    await _save();
                  },
                ),
                const Divider(color: Colors.white24),
                _SectionLabel('Images'),
                ListTile(
                  leading:
                      const Icon(Icons.add_photo_alternate, color: Colors.white),
                  title: Text(
                    _userImagePaths.isEmpty
                        ? 'Add photos from gallery'
                        : 'Add more photos (${_userImagePaths.length} selected)',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: _addPhotos,
                ),
                if (_userImagePaths.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.restore, color: Colors.white54),
                    title: const Text('Reset to bundled images',
                        style: TextStyle(color: Colors.white54)),
                    onTap: _resetImages,
                  ),
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                letterSpacing: 1.2)),
      );
}
