import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils.dart';

class ForecastChangeNotifier extends ChangeNotifier {
  final _weatherService = WeatherService();

  NotifierState _state = NotifierState.initial;
  NotifierState get state => _state;
  void _setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  // Demo UI purposes
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  Either<Failure, ForecastResponse>? _forecast;
  Either<Failure, ForecastResponse>? get forecast => _forecast;
  void _setForecast(Either<Failure, ForecastResponse> forecast) {
    _forecast = forecast;
    notifyListeners();
  }

  // User location and selected city
  void getForecastWeatherByLocation(String lat, String lon) async {
    _setState(NotifierState.loading);
    await Task(() => _weatherService.getForecastWeatherByLocation(lat, lon))
        .attempt()
        .mapLeftToFailure()
        .run()
        .then((value) => _setForecast(value as Either<Failure, ForecastResponse>));
    _setState(NotifierState.loaded);
  }
}
