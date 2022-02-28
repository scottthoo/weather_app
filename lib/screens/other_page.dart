// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/constants.dart';
import 'package:weather_app/models/cities_mock.dart';
import 'package:weather_app/utils.dart';
import 'package:weather_app/widgets/city_widget.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({Key? key}) : super(key: key);

  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  List<Widget> _citiesCard = [];
  String _selected = 'Kuala Lumpur';
  List<String> _myCities = [];

  ScrollController _scrollController = ScrollController();

  List<Widget> getCitiesWidgets() {
    List<Widget> cd = [];
    _myCities = UserPreferences.getCities();

    if (_myCities.isEmpty) {
      _myCities = ['Kuala Lumpur', 'Johor', 'Alor Setar'];
    }
    var cityName;
    for (cityName in _myCities) {
      print('city : $cityName');
      cd.add(CityWidget(cityName: cityName));
    }
    return cd;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      setState(() {
        _citiesCard = getCitiesWidgets();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: kNeutralDark,
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  height: 300,
                  child: Center(
                    child: buildDropDownCity(),
                  ),
                ),
              ),
            ),
          ).then((value) async {
            print('value : ${value}');
            setState(() {
              _selected = value;
              print("Testing Value: $_selected");
              _citiesCard.add(CityWidget(cityName: _selected));
              _myCities.add(_selected);
              UserPreferences.setCities(_myCities);
            });
            Future.delayed(Duration(milliseconds: 500)).then((value) => _scrollDown());
          });
        },
        backgroundColor: kNeutralLight,
      ),
      backgroundColor: kNeutralLight,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text("Today", style: kLargeTitleStyle),
                  SizedBox(width: 15),
                  Text(
                    DateFormat('dd-MMM-yyyy').format(DateTime.now()),
                    style: kTitle1Style,
                  ),
                ],
              ),
              ..._citiesCard,
            ],
          ),
        ),
      ),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  Container buildDropDownCity() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          buttonColor: kNeutralLight,
          alignedDropdown: true,
          child: DropdownButton<String>(
            isDense: true,
            hint: const Text("Select a city"),
            value: _selected,
            onChanged: (newValue) {
              setState(() {
                _selected = newValue.toString();
                Navigator.pop(context, _selected);
              });
            },
            items: kCities.map((Map map) {
              return DropdownMenuItem<String>(
                value: map["city"].toString(),
                child: Text(
                  map["city"],
                  style: kSubtitleStyle,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
