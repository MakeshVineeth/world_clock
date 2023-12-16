import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock/commons.dart';
import 'package:flutter_clock/display_date.dart';
import 'package:flutter_clock/locations_list/locations.dart';
import 'package:flutter_clock/services/data_methods.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TimeProvider _timeProvider;
  final MethodChannel _androidAppRetain = MethodChannel("android_app_exit");
  final Duration duration = const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    _timeProvider = context.read<TimeProvider>();

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ResizeImage(
            AssetImage('images/' + getDynamicBg(_timeProvider)),
            width: MediaQuery.of(context).size.width.round(),
            height: MediaQuery.of(context).size.height.round(),
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => DataMethods().getNewTimeData(_timeProvider),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: DisplayDate(),
              ),
            ),
          ),
        ),
        floatingActionButton: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Text(
                'Change Location',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Text(
                'Play Store',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: Text(
                'GitHub',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuItem(
              value: 5,
              child: Text(
                'Exit',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          offset: Offset(0, 50),
          elevation: 5.0,
          color: Colors.white,
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onSelected: (int value) => executeMenuItems(value),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      ),
    );
  }

  void executeMenuItems(int val) {
    switch (val) {
      case 1:
        changeLocation();
        break;
      case 2:
        Commons.launch(
            url:
                'https://play.google.com/store/apps/details?id=com.makeshtech.clock');
        break;
      case 3:
        Commons.launch(url: 'https://github.com/MakeshVineeth/world_clock');
        break;
      case 4:
        displayAbout();
        break;
      case 5:
        if (Platform.isAndroid)
          _androidAppRetain.invokeMethod("sendToBackground");
        else if (!Platform.isIOS)
          exit(
              0); // Not allowed on IOS as it's against Apple Human Interface guidelines to exit the app programmatically.
        break;
    }
  }

  void displayAbout() => showAboutDialog(
        context: context,
        applicationName: 'Flutter Clock',
        applicationIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            width: 35.0,
            image: AssetImage('images/time_zone.png'),
          ),
        ),
        applicationVersion: '2.0.3',
        applicationLegalese:
            'An Internet based World Clock app made in Flutter. It can retrieve timezones using the WorldClassAPI.',
      );

  void changeLocation() => Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, anim, anim1) => ChangeNotifierProvider.value(
            value: _timeProvider,
            child: Location(),
          ),
          transitionsBuilder: (context, anim, anim1, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
        ),
      );

  String getDynamicBg(TimeProvider timeProvider) {
    bool flag = timeProvider.worldTime.isDayTime;

    if (flag) {
      return 'day.gif';
    } else {
      return 'night.gif';
    }
  }
}
