import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Commons {
  static final circleRadius = BorderRadius.circular(20);
  static const MaterialColor materialColor = Colors.blue;
  static const Color bgColor = Colors.blue;

  static ThemeData getColorData(BuildContext context) => ThemeData(
        primarySwatch: materialColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: bgColor,
          centerTitle: true,
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      );

  static Future<void> launchUrl(
      {@required String url,
      bool forceWebView = false,
      bool enableJavaScript = false}) async {
    try {
      String encoded = Uri.encodeFull(url);

      await launch(
        encoded,
        forceWebView: forceWebView,
        enableJavaScript: enableJavaScript,
      );
    } catch (_) {}
  }
}
