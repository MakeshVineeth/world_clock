import 'package:flutter/material.dart';
import 'package:flutter_clock/home.dart';
import 'package:flutter_clock/loading_indicator.dart';
import 'package:flutter_clock/services/data_methods.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class Loader extends StatefulWidget {
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  Widget _current = loadingIndicator();
  TimeProvider timeProvider;

  void getTimeData() async {
    final prefs = await SharedPreferences.getInstance();
    final location = prefs.getString('location') ?? 'Kolkata';
    final url = prefs.getString('url') ?? 'Asia/Kolkata';
    final flag =
        prefs.getString('flag') ?? 'https://www.countryflags.io/in/flat/32.png';
    WorldTime instance = await DataMethods()
        .getTime(location: location, url: url, flag: flag);

    timeProvider = TimeProvider(worldTime: instance);

    setState(() => _current = Home());
  }

  @override
  void initState() {
    super.initState();
    getTimeData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimeProvider>(
      create: (context) => timeProvider,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _current,
      ),
    );
  }

  Widget homeScreen() {
    return Home();
  }

  static Widget loadingIndicator() {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: LoadingIndicator(color: Colors.white),
    );
  }
}
