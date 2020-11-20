import 'package:flutter/material.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loader extends StatefulWidget {
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  void getTimeData() async {
    final prefs = await SharedPreferences.getInstance();
    final location = prefs.getString('location') ?? 'Kolkata';
    final url = prefs.getString('url') ?? 'Asia/Kolkata';
    final flag =
        prefs.getString('flag') ?? 'https://www.countryflags.io/in/flat/32.png';
    WorldTime instance =
        WorldTime(location: location, url: url, flag: flag);
    await instance.taskLoader();
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'location': instance.location,
        'time': instance.time,
        'isDayTime': instance.isDayTime,
        'listData': instance.listData,
        'flag': instance.flag,
        'date': instance.date,
        'url': instance.url,
        'secondsLeft': instance.secondsLeft
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getTimeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCircle(
              color: Colors.white,
              size: 50.0,
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              'Loading',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
