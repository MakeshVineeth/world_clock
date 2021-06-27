import 'dart:convert';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock/commons.dart';
import 'package:flutter_clock/loading_indicator.dart';
import 'package:flutter_clock/locations_list/location_item.dart';
import 'package:flutter_clock/services/data_methods.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuzzy/fuzzy.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  List<WorldTime> locations = [];
  Fuzzy<String> listOfLocations = Fuzzy([]);
  Map listData = {};

  TimeProvider timeProvider;

  bool _workInProgress = true;

  @override
  void initState() {
    super.initState();
    timeProvider = context.read<TimeProvider>();
    firstSetup();
  }

  void updateTime(WorldTime worldTime) async {
    try {
      if (mounted) setState(() => _workInProgress = true);

      final WorldTime instance = await DataMethods().getTime(
        location: worldTime.location,
        flag: worldTime.flag,
        url: worldTime.url,
      );

      if (timeProvider != null) timeProvider.change(instance);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('url', instance.url);
      await prefs.setString('location', instance.location);
      await prefs.setString('flag', instance.flag ?? '');

      Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _workInProgress = false);
    }
  }

  Future<void> firstSetup() async {
    try {
      locations.clear();
      List ins = await DataMethods().getList();

      if (ins.isEmpty) {
        if (mounted) setState(() => _workInProgress = false);
        return;
      }

      Map e = jsonDecode(await rootBundle.loadString('assets/countries.json'));

      for (var item in ins) {
        String listItem = item.toString();

        String flag = e['$listItem'].toString().toLowerCase();
        flag = 'icons/flags/png/$flag.png';

        if (flag.contains('null')) flag = null;

        listItem = listItem.replaceAll('[', '');
        listItem = listItem.replaceAll(' ', '');

        String countryName = listItem.replaceAll('/', ', ');
        countryName = countryName.replaceAll('_', ' ');

        WorldTime locationItem =
            WorldTime(url: listItem, location: countryName, flag: flag);

        locations.add(locationItem);
        listOfLocations.list.add(locationItem.url);

        if (mounted) setState(() => _workInProgress = false);
      }
    } catch (_) {
      if (mounted) setState(() => _workInProgress = false);
    }
  }

  Future<List<WorldTime>> search(String searchStr) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      List<WorldTime> lists = [];

      final result = listOfLocations.search(searchStr);
      result
          .map((r) => r.matches.first.arrayIndex)
          .forEach((int i) => lists.add(locations.elementAt(i)));

      return lists;
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Location'),
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: AnimatedCrossFade(
          firstChild: Container(
            height: double.maxFinite,
            child: SearchBar<WorldTime>(
              onSearch: search,
              suggestions: locations,
              onItemFound: (WorldTime found, int index) => LocationItem(
                worldTime: found,
                index: index,
                onTap: () => updateTime(found),
              ),
              searchBarStyle: SearchBarStyle(
                padding: EdgeInsets.all(5),
                borderRadius: Commons.circleRadius,
              ),
              minimumChars: 2,
              onError: (_) => Center(
                child: Text(
                  "Error",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              emptyWidget: Center(
                child: Text(
                  "No Results",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              cancellationWidget: Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 5.0,
                ),
                child: Icon(
                  Icons.search,
                ),
              ),
              hintText: "Search Timezones",
              searchBarPadding: EdgeInsets.all(15.0),
              listPadding: EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 5.0,
              ),
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              iconActiveColor: Colors.blue,
              loader: LoadingIndicator(),
              crossAxisCount: 1,
              mainAxisSpacing: 5,
            ),
          ),
          secondChild: LoadingIndicator(),
          crossFadeState: _workInProgress
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 450),
        ),
      ),
    );
  }
}
