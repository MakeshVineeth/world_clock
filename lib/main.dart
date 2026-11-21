import 'package:flutter/services.dart';
import 'package:flutter_clock/src/app/world_clock_app.dart';
import 'package:flutter_clock/src/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.homeOverlayStyle);
  runApp(const WorldClockApp());
}
