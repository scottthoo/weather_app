import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils.dart';

class WeatherChangeNotifier extends ChangeNotifier {
  final _weatherService = WeatherService();

  NotifierState _state = NotifierState.initial;
  NotifierState get state => _state;
  void _setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  // Public for Demo UI purposes
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  // Either Left = Failure, Right = Responses from API
  Either<Failure, WeatherResponse>? _weather;
  Either<Failure, WeatherResponse>? get weather => _weather;
  void _setWeather(Either<Failure, WeatherResponse> weather) {
    _weather = weather;
    notifyListeners();
  }

  // User Location
  void getWeatherByLocation(String lat, String lon) async {
    _setState(NotifierState.loading);
    await Task(() => _weatherService.getCurrentWeatherByLocation(lat, lon))
        .attempt()
        .mapLeftToFailure()
        .run()
        .then((value) => _setWeather(value as Either<Failure, WeatherResponse>));
    _setState(NotifierState.loaded);
  }

  // User select city
  void getWeatherByCity(String city) async {
    _setState(NotifierState.loading);
    await Task(() => _weatherService.getWeatherByCity(city))
        .attempt()
        .mapLeftToFailure()
        .run()
        .then((value) => _setWeather(value as Either<Failure, WeatherResponse>));
    _setState(NotifierState.loaded);
  }
}
