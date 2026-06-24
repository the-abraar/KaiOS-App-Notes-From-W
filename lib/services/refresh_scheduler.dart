import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../models/app_settings.dart';
import '../repositories/widget_data_repository.dart';
import 'image_service.dart';
import 'quote_service.dart';

const _taskName = 'com.inovacetech.quotewidget.refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName) {
      await _doRefresh();
    }
    return true;
  });
}

Future<void> _doRefresh() async {
  final prefs = await SharedPreferences.getInstance();
  final styleStr = prefs.getString('quote_style') ?? 'both';
  final style = QuoteStyle.values.firstWhere(
    (e) => e.name == styleStr,
    orElse: () => QuoteStyle.both,
  );
  final userPaths = prefs.getStringList('user_image_paths') ?? [];

  final quoteService = QuoteService();
  final imageService = ImageService();
  final repo = WidgetDataRepository();

  final quote = await quoteService.getRandomQuote(style);
  final imagePath = await imageService.getRandomImagePath(userPaths);
  await repo.saveAndUpdate(quote, imagePath);
}

class RefreshScheduler {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> schedule(int intervalMinutes) async {
    await Workmanager().cancelByUniqueName(_taskName);
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: Duration(minutes: intervalMinutes),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> runOnce() async {
    await _doRefresh();
  }
}
