import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static const _bundledCount = 33;

  final String? _testSharedDir;

  ImageService() : _testSharedDir = null;
  ImageService.forTesting({required String sharedDir})
      : _testSharedDir = sharedDir;

  Future<String> getSharedImagesDir() async {
    if (_testSharedDir != null) return _testSharedDir!;
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      final path = '${dir!.path}/images';
      await Directory(path).create(recursive: true);
      return path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/images';
      await Directory(path).create(recursive: true);
      return path;
    }
  }

  Future<void> initBundledImages() async {
    final sharedDir = await getSharedImagesDir();
    for (var i = 1; i <= _bundledCount; i++) {
      final dest = File('$sharedDir/bundled_$i.jpg');
      if (!dest.existsSync()) {
        final data = await rootBundle.load('assets/images/$i.jpg');
        await dest.writeAsBytes(data.buffer.asUint8List());
      }
    }
  }

  Future<List<String>> _getBundledPaths() async {
    final sharedDir = await getSharedImagesDir();
    return List.generate(
      _bundledCount,
      (i) => '$sharedDir/bundled_${i + 1}.jpg',
    ).where((p) => File(p).existsSync()).toList();
  }

  Future<String> getRandomImagePath(List<String> userPaths) async {
    final bundled = await _getBundledPaths();
    final pool = [...bundled, ...userPaths.where((p) => File(p).existsSync())];
    if (pool.isEmpty) return bundled.isNotEmpty ? bundled.first : '';
    return pool[Random().nextInt(pool.length)];
  }

  Future<String> copyUserImage(String sourcePath) async {
    final sharedDir = await getSharedImagesDir();
    final fileName = 'user_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = File('$sharedDir/$fileName');
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }
}
