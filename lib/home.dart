import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data = {};
  String flagURL;
  String location;
  String time;
  String date;
  String url;
  bool isDayTime;
  String bgImage;
  Color bgColor;
  Timer timer;
  int secondsLeft;

  Future<void> getTimeData() async {
    WorldTime instance = WorldTime(location: location, url: url, flag: flagURL);
    await instance.taskLoader();

    setState(() {
      data['time'] = instance.time;
      data['date'] = instance.date;
      data['isDayTime'] = instance.isDayTime;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isEmpty ? ModalRoute.of(context).settings.arguments : data;
    isDayTime = data['isDayTime'];
    bgImage = isDayTime ? "clouds_min.webp" : "night.gif";
    bgColor = isDayTime ? Color(0xFF0092AC) : Color(0xFF00002B);
    flagURL = data['flag'];
    location = data['location'];
    time = data['time'];
    secondsLeft = data['secondsLeft'];
    timer = Timer.periodic(
        Duration(seconds: secondsLeft), (Timer t) => getTimeData());
    date = data['date'];
    url = data['url'];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => getTimeData(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/$bgImage'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                // Outer Most Column for storing 3-dot menu and a child column that displays rest of the widgets with Expanded Widget
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Text('About'),
                      ),
                    ],
                    offset: Offset(0, 50),
                    elevation: 5.0,
                    color: Colors.white,
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    onSelected: (value) => showAboutDialog(
                      context: context,
                      applicationName: 'Flutter Clock',
                      applicationIcon: Image(
                        width: 30.0,
                        image: AssetImage('images/time_zone.png'),
                      ),
                      applicationVersion: '1.0.1',
                      applicationLegalese:
                          'An Internet based World Clock app made in Flutter. It can retrieve timezones and country flags using the WorldClassAPI and CountryFlagsAPI.',
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: '$flagURL'),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '$location',
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          '$time',
                          style: TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RaisedButton.icon(
                              onPressed: () async {
                                dynamic result = await Navigator.pushNamed(
                                    context, '/location');
                                try {
                                  setState(
                                    () {
                                      data = {
                                        'time': result['time'],
                                        'isDayTime': result['isDayTime'],
                                        'flag': result['flag'],
                                        'location': result['location'],
                                        'date': result['date'],
                                        'url': result['url'],
                                        'secondsLeft': result['secondsLeft']
                                      };
                                    },
                                  );
                                } catch (e) {}
                              },
                              color: Colors.white.withOpacity(0.8),
                              icon: Icon(
                                Icons.location_city,
                              ),
                              label: Text(
                                'Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 10.0,
                              hoverColor: Colors.lightBlue[50],
                              highlightColor: Colors.lightBlue,
                              focusColor: Colors.lightGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
