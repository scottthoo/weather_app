import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_app/constants.dart';
import 'package:weather_app/models/cities_mock.dart';
import 'package:weather_app/providers/forecast_provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/services/icon_parse.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // WeatherService _weatherService = WeatherService(); // Demo purpose
  late WeatherChangeNotifier _providerWeather;
  late ForecastChangeNotifier _providerForecast;
  Position? _position;
  String _selected = "Kuala Lumpur";
  String _selectedCityLon = "101.6953";
  String _selectedCityLat = "3.1478";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _providerWeather = Provider.of<WeatherChangeNotifier>(context, listen: false);
      _providerForecast = Provider.of<ForecastChangeNotifier>(context, listen: false);
      _position = await _determinePosition();
      if (_position != null) {
        _providerWeather.getWeatherByLocation(_position!.latitude.toString(), _position!.longitude.toString());
        _providerForecast.getForecastWeatherByLocation(_position!.latitude.toString(), _position!.longitude.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kNeutralLight,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              buildDropDownCity(),
              const SizedBox(height: 15),
              Text("Today", style: kLargeTitleStyle),
              const SizedBox(height: 5),
              Text(
                DateFormat('dd-MMM-yyyy').format(DateTime.now()),
                style: kTitle1Style,
              ),
              const SizedBox(height: 15),
              Consumer<WeatherChangeNotifier>(
                builder: (_, notifier, __) {
                  if (notifier.state == NotifierState.initial) {
                    return buildShimmer();
                  } else if (notifier.state == NotifierState.loading) {
                    return buildShimmer();
                  } else {
                    return notifier.weather!.fold(
                      (failure) => Text(failure.toString()),
                      (weather) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              child: BoxedIcon(
                                WeatherIcons.fromString(iconParse(weather.weatherInfo.id.toString())!,
                                    fallback: WeatherIcons.lunar_eclipse),
                                size: 128,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(color: kNeutralDark, width: 0.5),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '${weather.tempInfo.temperature.toStringAsFixed(0)}',
                                  style: kLargeTitleStyle.copyWith(fontSize: 42),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    "°C",
                                    style: kBodyLabelStyle,
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              weather.weatherInfo.description.toUpperCase(),
                              style: kCaptionLabelStyle,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              weather.cityName,
                              style: kSubtitleStyle,
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  // context.loaderOverlay.show();
                  if (_position != null) {
                    _providerWeather.setState(NotifierState.loading);
                    _providerForecast.setState(NotifierState.loading);
                    await Future.delayed(const Duration(milliseconds: 200))
                        .then((value) => context.loaderOverlay.hide());
                    _providerWeather.getWeatherByLocation(
                        _position!.latitude.toString(), _position!.longitude.toString());
                    _providerForecast.getForecastWeatherByLocation(
                        _position!.latitude.toString(), _position!.longitude.toString());
                    setState(() {
                      _selected = "Select a city";
                    });
                  } else {
                    _position = await _determinePosition();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Text(
                    "Get Current Location",
                    style: kSearchTextStyle.copyWith(color: Colors.white),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff73A0F4),
                        Color(0xff4A47F5),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Forecast",
                style: kCaptionLabelStyle,
              ),
              Consumer<ForecastChangeNotifier>(
                builder: (_, notifier, __) {
                  if (notifier.state == NotifierState.initial) {
                    return buildShimmerForecast();
                  } else if (notifier.state == NotifierState.loading) {
                    return buildShimmerForecast();
                  } else {
                    if (notifier.forecast != null) {
                      return notifier.forecast!.fold(
                        (failure) => Text(failure.toString()),
                        (forecast) {
                          var i = 0;
                          return Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                i += 7;
                                // String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
                                // print('forecast.list![$i].dtTxt : ${forecast.list![i].dtTxt}');
                                // print(
                                //     'forecast.list![$i].weather![0].description : ${forecast.list![i].weather![0].description}');
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat('dd-MM').format(forecast.list![i].dtTxt!),
                                        style: kSearchTextStyle,
                                      ),
                                      Container(
                                        child: BoxedIcon(
                                          WeatherIcons.fromString(
                                              iconParse(forecast.list![i].weather![0].id.toString())!,
                                              fallback: WeatherIcons.lunar_eclipse),
                                          size: 48,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14.0),
                                          border: Border.all(color: kNeutralDark, width: 0.5),
                                        ),
                                      ),
                                      Text(
                                        '${forecast.list![i].main!.temp?.toStringAsFixed(0)}°️',
                                        style: kCaptionLabelStyle,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const Text("ERROR");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Shimmer buildShimmer() {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 300),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(color: Colors.grey[400], borderRadius: const BorderRadius.all(Radius.circular(15))),
      ),
    );
  }

  SizedBox buildShimmerForecast() {
    return SizedBox(
      height: 80,
      width: MediaQuery.of(context).size.width - 50,
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 300),
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 100,
          decoration: BoxDecoration(color: Colors.grey[400], borderRadius: const BorderRadius.all(Radius.circular(15))),
        ),
      ),
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
                for (var map in kCities) {
                  if (map["city"] == _selected) {
                    _selectedCityLat = map["lat"];
                    _selectedCityLon = map["lng"];
                  }
                }
                _providerWeather.getWeatherByCity(_selected);
                _providerForecast.getForecastWeatherByLocation(_selectedCityLat, _selectedCityLon);
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

  void _getWeather() async {
    // final response = await _weatherService.getWeatherByCity(_selected);
    // setState(() => _response = response);
    _providerWeather.getWeatherByCity(_selected);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
