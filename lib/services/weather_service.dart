import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:weather_app/constants.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils.dart';

class WeatherService {
  Future<WeatherResponse> getWeatherByCity(String city) async {
    // api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}
    final queryParameters = {'q': city, 'appid': kAPIKey, 'units': 'metric'};
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', queryParameters);
    try {
      final response = await http.get(uri);
      log('response.body : ${response.body}');
      final json = jsonDecode(response.body);
      return WeatherResponse.fromJson(json);
    } on SocketException {
      throw Failure('No Internet connection.');
    } on HttpException {
      throw Failure("Failed to get Weather");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }

  Future<WeatherResponse> getCurrentWeather(String lat, String lon) async {
    // api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    final queryParameters = {'lat': lat, 'lon': lon, 'appid': kAPIKey, 'units': 'metric'};
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', queryParameters);
    try {
      final response = await http.get(uri);
      log('response.body : ${response.body}');

      final json = jsonDecode(response.body);
      return WeatherResponse.fromJson(json);
    } on SocketException {
      throw Failure('No Internet connection.');
    } on HttpException {
      throw Failure("Failed to get Weather");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }

  Future<WeatherResponse> getCurrentWeatherByLocation(String lat, String lon) async {
    // api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    final queryParameters = {'lat': lat, 'lon': lon, 'appid': kAPIKey, 'units': 'metric'};
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', queryParameters);

    try {
      final response = await http.get(uri);
      log('response.body : ${response.body}');

      final json = jsonDecode(response.body);
      return WeatherResponse.fromJson(json);
    } on SocketException {
      throw Failure('No Internet connection.');
    } on HttpException {
      throw Failure("Failed to get Weather");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }

  Future<ForecastResponse> getForecastWeatherByLocation(String lat, String lon) async {
    // api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
    final queryParameters = {'lat': lat, 'lon': lon, 'appid': kAPIKey, 'units': 'metric'};
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/forecast', queryParameters);
    log('uri : ${uri}');
    try {
      final response = await http.get(uri);
      log('response.body : ${response.body}');
      final json = jsonDecode(response.body);
      return ForecastResponse.fromJson(json);
    } on SocketException {
      throw Failure('No Internet connection.');
    } on HttpException {
      throw Failure("Failed to get Weather");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }
}
