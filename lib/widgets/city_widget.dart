import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_app/constants.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils.dart';
import 'package:weather_icons/weather_icons.dart';

class CityWidget extends StatefulWidget {
  final String cityName;

  const CityWidget({Key? key, required this.cityName}) : super(key: key);
  @override
  _CityWidgetState createState() => _CityWidgetState();
}

class _CityWidgetState extends State<CityWidget> {
  final WeatherService _weatherService = WeatherService();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: _weatherService.getWeatherByCity(widget.cityName),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text("Error");
            }
            if (snapshot.hasData) {
              WeatherResponse response = snapshot.data as WeatherResponse;
              return buildCard(
                  weatherId: response.weatherInfo.id.toString(),
                  desc: response.weatherInfo.description,
                  temp: response.tempInfo.temperature.toStringAsFixed(0));
            }
            return Text("No Data");
          }),
    );
  }

  void _fetchCityData() async {}

  SizedBox buildCard({required String temp, required String desc, required String weatherId}) {
    return SizedBox(
      // padding: EdgeInsets.symmetric(horizontal: 10),
      height: 280,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 15),
                    child: Text(
                      widget.cityName,
                      style: kSubtitleStyle,
                    ),
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(color: kNeutralDark, width: 0.5),
                        ),
                        child: BoxedIcon(
                          WeatherIcons.fromString(iconParse(weatherId)!, fallback: WeatherIcons.lunar_eclipse),
                          size: 120,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  temp,
                                  style: kLargeTitleStyle.copyWith(fontSize: 64),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Text(
                                    "°C",
                                    style: kBodyLabelStyle,
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            Text(desc),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Shimmer buildShimmer() {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 300),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 280,
        decoration: BoxDecoration(color: Colors.grey[400], borderRadius: const BorderRadius.all(Radius.circular(15))),
      ),
    );
  }
}
