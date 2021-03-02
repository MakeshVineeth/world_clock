import 'package:flutter/material.dart';
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
  TimeProvider _timeProvider;
  @override
  Widget build(BuildContext context) {
    Commons.setStatusBarColor(context: context);
    _timeProvider = Provider.of<TimeProvider>(context, listen: false);

    return Consumer<TimeProvider>(
      builder: (context, timeProvider, child) => Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/' + getDynamicBg(timeProvider)),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topRight,
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        'About',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(
                        'Change Location',
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
                  onSelected: (value) => executeMenuItems(value),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => DataMethods().getTimeData(
                      Provider.of<TimeProvider>(context, listen: false)),
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
            ],
          ),
        ),
      ),
    );
  }

  void executeMenuItems(int val) {
    switch (val) {
      case 1:
        displayAbout();
        break;
      case 2:
        changeLocation();
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
        applicationVersion: '2.0.0',
        applicationLegalese:
            'An Internet based World Clock app made in Flutter. It can retrieve timezones and country flags using the WorldClassAPI and CountryFlagsAPI.',
      );

  void changeLocation() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: _timeProvider,
            child: Location(),
          ),
        ));
  }

  String getDynamicBg(TimeProvider timeProvider) {
    return timeProvider.worldTime.isDayTime ? "day.gif" : "night.gif";
  }
}
