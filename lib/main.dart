import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'services/image_service.dart';
import 'services/refresh_scheduler.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.setAppGroupId('group.com.inovacetech.quotewidget');
  await RefreshScheduler.init();

  // Extract bundled images to shared dir on first run
  await ImageService().initBundledImages();

  // Schedule default refresh if not yet scheduled
  await RefreshScheduler.schedule(30);

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
