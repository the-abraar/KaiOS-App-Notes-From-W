import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'services/image_service.dart';
import 'services/refresh_scheduler.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HomeWidget.setAppGroupId('group.com.the_abraar.quote_widget_app');
  } catch (_) {}
  try {
    await RefreshScheduler.init();
  } catch (_) {}
  try {
    await ImageService().initBundledImages();
  } catch (_) {}
  try {
    await RefreshScheduler.schedule(30);
  } catch (_) {}

  runApp(const QuoteWidgetApp());
}

class QuoteWidgetApp extends StatelessWidget {
  const QuoteWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quote Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(),
      ),
      home: const MainScreen(),
    );
  }
}
