import 'dart:convert';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock/commons.dart';
import 'package:flutter_clock/locations_list/location_item.dart';
import 'package:flutter_clock/services/data_methods.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  List<WorldTime> locations = [];
  Map listData = {};

  TimeProvider timeProvider;

  @override
  void initState() {
    super.initState();
    firstSetup();
  }

  void updateTime(int index) async {
    try {
      WorldTime instance = await DataMethods().taskLoader(
        location: locations[index].location,
        flag: locations[index].flag,
        url: locations[index].url,
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('url', instance.url);
      prefs.setString('flag', instance.flag);
      prefs.setString('location', instance.location);
      Navigator.pop(context);

      timeProvider.change(instance);
    } catch (e) {
      print(e);
    }
  }

  void firstSetup() async {
    try {
      List ins = await DataMethods().getList();
      Map e = jsonDecode(await rootBundle.loadString('assets/countries.json'));
      for (var item in ins) {
        String listItem = item.toString();

        String flag = e['$listItem'].toString().toLowerCase();
        flag = 'https://www.countryflags.io/$flag/flat/32.png';

        if (flag.contains('null')) flag = null;

        listItem = listItem.replaceAll('[', '');
        listItem = listItem.replaceAll(' ', '');

        var temp = listItem.split('/');
        String countryName = temp[temp.length - 1];
        countryName = countryName.replaceAll('_', ' ');

        setState(() => locations
            .add(WorldTime(url: listItem, location: countryName, flag: flag)));
      }
    } catch (e) {}
  }

  Future<List<WorldTime>> search(String searchStr) async {
    await Future.delayed(Duration(seconds: 1));
    List<WorldTime> lists = [];
    for (var i = 0; i < locations.length; i++) {
      String locationURL = locations[i].url.toLowerCase().replaceAll('_', '');
      String searchFormatted = searchStr.toLowerCase().replaceAll(' ', '');
      if (locationURL.contains(searchFormatted)) {
        lists.add(locations.elementAt(i));
      }
    }
    return lists;
  }

  @override
  Widget build(BuildContext context) {
    timeProvider = Provider.of<TimeProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose Location'),
          centerTitle: true,
          backgroundColor: Colors.blue[900],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: SearchBar<WorldTime>(
            onSearch: search,
            suggestions: locations,
            onItemFound: (WorldTime foundCard, int index) {
              return LocationItem(
                worldTime: foundCard,
                index: index,
                onTap: () => updateTime(index),
              );
            },
            searchBarStyle: SearchBarStyle(
              padding: EdgeInsets.all(5),
              borderRadius: Commons.circleRadius,
            ),
            minimumChars: 2,
            onError: (error) {
              return Center(
                child: Text(
                  "Error occurred : $error",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
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
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
              child: Icon(
                Icons.search,
              ),
            ),
            hintText: "Type here to search...",
            searchBarPadding: EdgeInsets.all(15.0),
            listPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            iconActiveColor: Colors.blue,
            loader: CircularProgressIndicator(),
            crossAxisCount: 1,
            mainAxisSpacing: 5,
          ),
        ));
  }
}
