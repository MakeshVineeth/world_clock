import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Commons {
  static final circleRadius = BorderRadius.circular(20);

  static ThemeData getColorData(BuildContext context) {
    Color bgColor = Colors.blue;
    MaterialColor materialColor = Colors.blue;

    return ThemeData(
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
  }

  static void launchUrl(
      {@required String url,
      bool forceWebView = false,
      bool enableJavaScript = false}) async {
    try {
      await launch(url,
          forceWebView: forceWebView, enableJavaScript: enableJavaScript);
    } catch (e) {
      print(e);
    }
  }
}
