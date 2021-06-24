import 'package:flutter/material.dart';
import 'package:flutter_clock/home.dart';
import 'package:flutter_clock/loading_indicator.dart';
import 'package:flutter_clock/services/data_methods.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';

import 'package:provider/provider.dart';

class Loader extends StatefulWidget {
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  Widget _current = loadingIndicator();
  TimeProvider timeProvider;

  void getTimeData() async {
    WorldTime _worldTime = await DataMethods().getDefaultClock();
    timeProvider = TimeProvider(worldTime: _worldTime);
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

  Widget homeScreen() => Home();

  static Widget loadingIndicator() => const Scaffold(
        backgroundColor: Colors.blueAccent,
        body: LoadingIndicator(color: Colors.white),
      );
}
